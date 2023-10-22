<div align="center"><h1>Integrating Terraform Cloud with GitHub Actions workflow</h1></div>

## What is Terraform Cloud?
Terraform Cloud is a web-based SaaS (Software as a Service) platform provided by HashiCorp, the creators of Terraform. It serves as a central hub for managing and automating infrastructure provisioning using HashiCorp's Infrastructure as Code (IaC) tool, Terraform. Terraform Cloud enhances the deployment workflow by offering features such as remote execution, collaboration, version control integration, and secure state management.


## Why should we use Terraform Cloud over Terraform Open Source?
1. HashiCorp announced that now Terraform will not be fully open source. [Link to article](https://www.hashicorp.com/blog/hashicorp-adopts-business-source-license)
2. Better and secure State management - HashiCorp provides feature of keeping the state file in TFC workspace and also provides an option to lock that state i.e, one cannot write upon the locked state.
3. Remote execution.
4. TFC has their own agents which works well with Terraform.
5. TFC provides HashiCorp's Sentinel policies which can help in integrating Policy-as-Code in our infrastructure.

## Why integrating TFC with GH Actions workflow?
TFC can handle only Terraform steps/commands ,i.e, terraform init, terraform validate, terraform plan, terraform apply. So, if you are having any other step, or any of your jobs are using some other scripts, then you might need GitHub Action for running those scripts, which will run on either GitHub runners or Self hosted runners.

## Integration Steps
- Create a new Workspace in [Terraform Cloud](https://app.terraform.io/).
- Choose API-driven workflow.
![API driven workflow based TFC workspace](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/qr2602gh3tze75ysgnps.png)
We choose API-driven workflow because we are integrating TFC with GitHub Actions so the API token will be used by GitHub Actions for authentication in TFC workspace. [Read more on API-driven workflow](https://developer.hashicorp.com/terraform/cloud-docs/run/api)
- Provide the workspace a name.
![TFC workspace name](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/cwj6qjlbmrspxyaxm9pn.png)
- Tap on **Create Workspace** button.
- Create a GitHub repository where you would be adding your TF code and GitHub Actions workflow files. 
- Let's now create the API token in TFC.
 - Go to the home page of your TFC organization - https://app.terraform.io/app/<ORGANIZATION NAME>/workspaces
 - Open Settings.
![Choosing Settings option in TFC](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/bqe540ymlb7xocy1f2s7.png)
 - Choose **API tokens** section.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/aws62hu0qvo0atdqu0k4.png)
There are 3 categories of token which one can generate:
     - User Token - In a TFC organization, many users can be a part. So, this token is generated by a single user.
     - Team Token - This token is generated by a team.
     - Organization Token - This token is generated for the whole organization. 

    All tokens have similar access, it's just that all users or teams should not have access to all tokens.
  - We are creating the User token. 
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/wqo61og9vs06j23dchqg.png)
  - Add a description and set the expiration time period of that token, and Generate the token.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/s859d63pr6w5ytb1kgwy.png)
  - Copy and store the generated API token.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/xcdfb5posesrcns5ksl1.png)
- Now get back to your repository Settings->Secrets and variables->Actions. And tap on **New repository secret** to add the TFC API token as secret in the GitHub repository.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/h093l1mdvsz6y5ti3qnm.png)
- Add the secret name(prefer adding the same name as you added while creating the token. In the **Secret** section add the generated token. Click **Add secret**.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/qljyazb5uekum7tmdne4.png)
- Add your SPN details (such as Client ID, Client Secret, Tenant ID) and subscription details in TFC workspace variables.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/hgqmrc1v4yk92k59k5hc.png)
- Now it's time to add some TF code in your GitHub repo along with the Terraform providers block with specific details of your TFC workspace. These details are important for your connection and deployment via TFC.
```
terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
    }

    random = {
        source = "hashicorp/random"
    }
  }

  cloud {
    organization = "aniketkumarsinha"

    workspaces {
      name = "tfc-integration-with-gh-actions"
    }
  }
}
```
- Time to work on the integrated GitHub Actions workflow creation!
.github/workflows/deploy.yml
```
name: WORKFLOW

on:
  workflow_dispatch:
    
jobs:
  terraform:
    name: "Terraform"
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v2

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.1.7
        cli_config_credentials_token: ${{ secrets. TF_API_TOKEN }}

    - name: Terraform Init
      id: init
      run: terraform init
        
    - name: Terraform Validate
      id: validate
      run: terraform validate -no-color
      
    - name: Terraform Plan
      id: plan
      run: terraform plan -no-color -input=false
      
    - name: Terraform Apply
      id: apply
      run: terraform apply -auto-approve -input=false
```
We created an integrated workflow file that connects the GitHub actions workflow with the TFC workspace run. When you run this workflow, you can see a simultaneous run over TFC workflow, both the runs are the same, it's just that the real TF code run is running on TFC workspace and a copy/replica is shown up in the GitHub actions workflow run.

Hola!! Pipeline running successfully ✅
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/0wlxe8bl6ub0rekkibgz.png)

You can check the TFC workflow run and you can also get that link from the Terraform Plan or Terraform Apply phase:
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/d9ajdsvxew8xzljslyy0.png)

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/qjy5yywoniwduy1q209b.png)


















