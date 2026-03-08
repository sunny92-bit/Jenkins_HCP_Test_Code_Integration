pipeline {

    agent any

    environment {

        // Terraform Cloud API Token stored in Jenkins credentials
        TF_TOKEN_app_terraform_io = credentials('terraform-cloud-token')
        TFC_TOKEN = credentials('terraform-cloud-token')

        // Terraform Cloud configuration
        TFC_ORG = "SunnyOrg92"
        TFC_WORKSPACE = "Jenkins_HCP_Test_Code_Integration"

        // Terraform Cloud API URL
        TFC_API = "https://app.terraform.io/api/v2"

    }

    options {
        timestamps()
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo "Checking out Terraform repository..."
                git branch: 'master', url: 'https://github.com/sunny92-bit/Jenkins_HCP_Test_Code_Integration.git'
            }
        }

        stage('Terraform Format Check') {
            steps {
                echo "Checking Terraform formatting..."
                sh '''
                terraform fmt -check -recursive
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                echo "Initializing Terraform..."
                sh '''
                terraform init
                '''
            }
        }

        stage('Terraform Validate') {
            steps {
                echo "Validating Terraform configuration..."
                sh '''
                terraform validate
                '''
            }
        }

        stage('Security Scan') {
            steps {
                echo "Running Terraform security scan..."
                sh '''
                checkov -d .
                '''
            }
        }

        stage('Trigger Terraform Cloud Run') {
            steps {
                script {

                    echo "Fetching Workspace ID..."

                    WORKSPACE_ID = sh(
                        script: """
                        curl -s \
                        --header "Authorization: Bearer ${TFC_TOKEN}" \
                        --header "Content-Type: application/vnd.api+json" \
                        ${TFC_API}/organizations/${TFC_ORG}/workspaces/${TFC_WORKSPACE} \
                        | jq -r '.data.id'
                        """,
                        returnStdout: true
                    ).trim()

                    echo "Workspace ID: ${WORKSPACE_ID}"

                    echo "Triggering Terraform Cloud Run..."

                    sh """
                    curl \
                    --header "Authorization: Bearer ${TFC_TOKEN}" \
                    --header "Content-Type: application/vnd.api+json" \
                    --request POST \
                    --data '{
                      "data": {
                        "attributes": {
                          "message": "Triggered from Jenkins Pipeline"
                        },
                        "type":"runs",
                        "relationships": {
                          "workspace": {
                            "data": {
                              "type": "workspaces",
                              "id": "${WORKSPACE_ID}"
                            }
                          }
                        }
                      }
                    }' \
                    ${TFC_API}/runs
                    """

                }
            }
        }

        stage('Approval') {
            steps {
                input message: "Approve Terraform Apply?", ok: "Apply"
            }
        }

    }

    post {

        success {
            echo "Pipeline completed successfully"
        }

        failure {
            echo "Pipeline failed"
        }

    }

}