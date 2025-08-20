package test

import (
	"fmt"
	"testing"
	"strings"
	"context"
	"os"

	helper "github.com/cloudposse/test-helpers/pkg/atmos/component-helper"
	"github.com/cloudposse/test-helpers/pkg/atmos"
	"github.com/stretchr/testify/assert"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/google/go-github/v73/github"
	"github.com/gruntwork-io/terratest/modules/aws"
)

type ComponentSuite struct {
	helper.TestSuite
}

func (s *ComponentSuite) TestBasic() {
	const component = "example/basic"
	const stack = "default-test"
	const awsRegion = "us-east-2"

	randomRepositoryName := strings.ToLower(random.UniqueId())
	repoName := fmt.Sprintf("component-test-%s", randomRepositoryName)
	owner := "cloudposse-tests"

	createdParameterName := strings.ToLower(random.UniqueId())
	createdParameterValue := strings.ToLower(random.UniqueId())
	ssmSecretPath := fmt.Sprintf("/cp/prod/app/database/%s", createdParameterName)
	aws.PutParameter(s.T(), awsRegion, ssmSecretPath, "Parameter for github-repository component testing", createdParameterValue)
	defer aws.DeleteParameter(s.T(), awsRegion, ssmSecretPath)


	createdSecretName := strings.ToLower(random.UniqueId())
	createdSecretValue := strings.ToLower(random.UniqueId())
	smSecretPath := aws.CreateSecretStringWithDefaultKey(s.T(), awsRegion, "Parameter for github-repository component testing", createdSecretName, createdSecretValue)
	defer aws.DeleteSecret(s.T(), awsRegion, createdSecretName, true)


	input := map[string]interface{}{
		"repository": map[string]interface{}{
			"name": repoName,
			"description": "Terraform acceptance tests for component",
			"homepage_url": "http://example.com/",
			"topics": []interface{}{"terraform", "github", "test"},
			"default_branch": "main",

			"is_template": true,

			"auto_init": true,
			"gitignore_template": "TeX",
			"license_template": "GPL-3.0",

			"archived": false,
			"archive_on_destroy": false,

			"has_issues": true,
			"has_discussions": true,
			"has_projects": true,
			"has_wiki": true,
			"has_downloads": true,

			"allow_merge_commit": true,
			"allow_squash_merge": true,
			"allow_rebase_merge": true,
			"allow_auto_merge": true,

			"merge_commit_title": "MERGE_MESSAGE",
			"merge_commit_message": "PR_TITLE",
			"squash_merge_commit_title": "COMMIT_OR_PR_TITLE",
			"squash_merge_commit_message": "COMMIT_MESSAGES",

			"web_commit_signoff_required": true,
			"delete_branch_on_merge": true,

			"ignore_vulnerability_alerts_during_read": true,
			"allow_update_branch": true,

			"security_and_analysis": map[string]interface{}{
				"advanced_security": false,
				"secret_scanning": true,
				"secret_scanning_push_protection": true,
			},
		},
		"variables": map[string]interface{}{
			"test_variable": fmt.Sprintf("ssm://%s", ssmSecretPath),
			"test_variable_2": fmt.Sprintf("asm://%s", createdSecretName),
		},
		"secrets": map[string]interface{}{
			"test_secret": fmt.Sprintf("ssm://%s", ssmSecretPath),
			"test_secret_2": fmt.Sprintf("asm://%s", createdSecretName),
		},
		"environments": map[string]interface{}{
			"development": map[string]interface{}{
				"wait_timer": 5,
				"can_admins_bypass": false,
				"prevent_self_review": false,
				"variables": map[string]interface{}{
					"test_variable": "test-value",
				},
			},
			"production": map[string]interface{}{
				"wait_timer": 10,
				"can_admins_bypass": false,
				"prevent_self_review": false,
				"deployment_branch_policy": map[string]interface{}{
					"protected_branches": false,
					"custom_branches": map[string]interface{}{
						"branches": []interface{}{"main"},
						"tags": []interface{}{"v1.0.0"},
					},
				},
				"secrets": map[string]interface{}{
					"test_secret": "test-value",
					"test_secret_2": "nacl:dGVzdC12YWx1ZS0yCg==",
				},
			},
			"staging": map[string]interface{}{
				"wait_timer": 0,
				"can_admins_bypass": false,
				"prevent_self_review": false,
				"variables": map[string]interface{}{
					"test_variable": fmt.Sprintf("ssm://%s", ssmSecretPath),
					"test_variable_2": fmt.Sprintf("asm://%s", smSecretPath),
				},
				"secrets": map[string]interface{}{
					"test_secret": fmt.Sprintf("ssm://%s", ssmSecretPath),
					"test_secret_2": fmt.Sprintf("asm://%s", smSecretPath),
				},
			},
		},
	}

	defer s.DestroyAtmosComponent(s.T(), component, stack, &input)

	options, _ := s.DeployAtmosComponent(s.T(), component, stack, &input)
	assert.NotNil(s.T(), options)

	s.DriftTest(component, stack, &input)

	repositoryNameOutputs := atmos.Output(s.T(), options, "full_name")
	assert.Equal(s.T(), fmt.Sprintf("%s/%s", owner, repoName), repositoryNameOutputs)

	token := os.Getenv("GITHUB_TOKEN")

	client := github.NewClient(nil).WithAuthToken(token)

	repo, _, err := client.Repositories.Get(context.Background(), owner, repoName)
	assert.NoError(s.T(), err)

	assert.Equal(s.T(), repoName, repo.GetName())
	assert.Equal(s.T(), "Terraform acceptance tests for component", repo.GetDescription())
	assert.Equal(s.T(), "http://example.com/", repo.GetHomepage())
	assert.Equal(s.T(), false, repo.GetPrivate())
	assert.Equal(s.T(), "public", repo.GetVisibility())

	// Additional assertions for repository attributes
	assert.Equal(s.T(), false, repo.GetArchived())
	assert.Equal(s.T(), true, repo.GetHasIssues())
	assert.Equal(s.T(), true, repo.GetHasProjects())
	assert.Equal(s.T(), true, repo.GetHasDiscussions())
	assert.Equal(s.T(), true, repo.GetHasWiki())
	assert.Equal(s.T(), true, repo.GetHasDownloads())
	assert.Equal(s.T(), true, repo.GetIsTemplate())
	assert.Equal(s.T(), true, repo.GetAllowSquashMerge())
	assert.Equal(s.T(), "COMMIT_OR_PR_TITLE", repo.GetSquashMergeCommitTitle())
	assert.Equal(s.T(), "COMMIT_MESSAGES", repo.GetSquashMergeCommitMessage())
	assert.Equal(s.T(), true, repo.GetAllowMergeCommit())
	assert.Equal(s.T(), "MERGE_MESSAGE", repo.GetMergeCommitTitle())
	assert.Equal(s.T(), "PR_TITLE", repo.GetMergeCommitMessage())
	assert.Equal(s.T(), true, repo.GetAllowRebaseMerge())
	assert.Equal(s.T(), true, repo.GetWebCommitSignoffRequired())
	assert.Equal(s.T(), true, repo.GetDeleteBranchOnMerge())
	assert.Equal(s.T(), "main", repo.GetDefaultBranch())
	assert.Equal(s.T(), true, repo.GetAllowUpdateBranch())

	vars, _, err := client.Actions.ListRepoVariables(context.Background(), owner, repoName, nil)
	assert.NoError(s.T(), err)
	assert.NotNil(s.T(), vars)
	assert.Equal(s.T(), 2, len(vars.Variables))

	assert.Equal(s.T(), createdParameterValue, vars.Variables[0].Value)
	assert.Equal(s.T(), "TEST_VARIABLE", vars.Variables[0].Name)

	assert.Equal(s.T(), createdSecretValue, vars.Variables[1].Value)
	assert.Equal(s.T(), "TEST_VARIABLE_2", vars.Variables[1].Name)

	envVars, _, err := client.Actions.ListEnvVariables(context.Background(), owner, repoName, "staging", nil)
	assert.NoError(s.T(), err)
	assert.NotNil(s.T(), envVars)
	assert.Equal(s.T(), 2, len(envVars.Variables))

	assert.Equal(s.T(), "TEST_VARIABLE", envVars.Variables[0].Name)
	assert.Equal(s.T(), createdParameterValue, envVars.Variables[0].Value)

	assert.Equal(s.T(), "TEST_VARIABLE_2", envVars.Variables[1].Name)
	assert.Equal(s.T(), createdSecretValue, envVars.Variables[1].Value)
}

func (s *ComponentSuite) TestTemplate() {
	const component = "example/template"
	const stack = "default-test"
	const awsRegion = "us-east-2"

	randomRepositoryName := strings.ToLower(random.UniqueId())
	repoName := fmt.Sprintf("component-test-%s", randomRepositoryName)
	owner := "cloudposse-tests"

	input := map[string]interface{}{
		"repository": map[string]interface{}{
			"name": repoName,
		},
	}


	options, _ := s.DeployAtmosComponent(s.T(), component, stack, &input)
	assert.NotNil(s.T(), options)

	// Use atmos.DestroyE instead of s.DestroyAtmosComponent due to weired race condition for tofu > 1.9.0 on destroy.
	// The issue does not affect tear down resources but exit code is 1.
	defer func() {
		atmos.DestroyE(s.T(), options)
	}()

	s.DriftTest(component, stack, &input)

	repositoryNameOutputs := atmos.Output(s.T(), options, "full_name")
	assert.Equal(s.T(), fmt.Sprintf("%s/%s", owner, repoName), repositoryNameOutputs)

	token := os.Getenv("GITHUB_TOKEN")

	client := github.NewClient(nil).WithAuthToken(token)

	repo, _, err := client.Repositories.Get(context.Background(), owner, repoName)
	assert.NoError(s.T(), err)

	assert.Equal(s.T(), repoName, repo.GetName())

	readmeContent, _, err := client.Repositories.GetReadme(context.Background(), owner, repoName, nil)
	assert.NoError(s.T(), err)

	readmeData, err := readmeContent.GetContent()
	assert.NoError(s.T(), err)
	assert.Contains(s.T(), readmeData, "test-terraform-github-repository-template")
}

func (s *ComponentSuite) TestImport() {
	const component = "example/import"
	const stack = "default-test"
	const awsRegion = "us-east-2"

	// s.DeployAtmosComponent(s.T(), component, stack, nil)
	input := map[string]interface{}{
		"users": map[string]interface{}{
			"cloudposse-test-bot": "pull",
		},
	}

	s.DriftTest(component, stack, &input)
}


func (s *ComponentSuite) TestEnabledFlag() {
	const component = "example/disabled"
	const stack = "default-test"
	s.VerifyEnabledFlag(component, stack, nil)
}

func TestRunSuite(t *testing.T) {
	suite := new(ComponentSuite)
	helper.Run(t, suite)
}
