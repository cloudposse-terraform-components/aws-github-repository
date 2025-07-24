Provision a GitHub repository and set repository secrets and variables from AWS Secrets Manager and AWS Systems Manager Parameter Store.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.
```yaml
components:
  terraform:
    example/aws-github-repository:
      vars:
        enabled: true
        owner: acme-github-org
        repository:
          name: "my-repository"
          description: "My repository"
          homepage_url: "http://example.com/"
          topics:
            - terraform
            - github
            - test
        default_branch: "main"
        secrets:
          MY_SECRET: "my-secret-value"
          MY_SECRET_2: "nacl:dGVzdC12YWx1ZS0yCg=="
          MY_SECRET_3: "ssm:/my/secret/path"
          MY_SECRET_4: "sm:secret-name"
        variables:
          MY_VARIABLE: "my-variable-value"
          MY_VARIABLE_2: "ssm:/my/variable/path"
          MY_VARIABLE_3: "sm:variable-name"
```

## Secrets and variables

The component supports setting repository and environment secrets and variables. 
Secrets and variables can be set using the following methods:
- Raw values (unencrypted string) (example: `my-secret-value`)
- AWS Secrets Manager (SM) (example: `sm:secret-name`)
- AWS Systems Manager Parameter Store (SSM) (example: `ssm:/my/secret/path`)

In addition to that secrets supports base64 encoded values [encrypted](https://docs.github.com/en/rest/guides/encrypting-secrets-for-the-rest-api?apiVersion=2022-11-28) 
with [repository key](https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#get-a-repository-public-key).
The value should be prefixed with `nacl:` (example: `nacl:dGVzdC12YWx1ZS0yCg==`).

## Import mode

The component supports importing existing repository and it's configs:
- collaborators
- variables
- environments
- environment variables
- labels
- custom properties values
- autolink references
- deploy keys

Import mode is enabled by setting `import` input variable to `true`.

The following configs are not supported for import:
- secrets
- environment secrets
- branch protection policies
- rulesets

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->
