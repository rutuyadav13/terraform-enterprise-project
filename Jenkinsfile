pipeline {

    agent any

    options {
        timestamps()
        ansiColor('xterm')
        disableConcurrentBuilds()

        buildDiscarder(
            logRotator(
                numToKeepStr: '10'
            )
        )
    }

    parameters {

        choice(
            name: 'ENV',
            choices: ['dev', 'stage', 'prod'],
            description: 'Select Environment'
        )
    }

    environment {

        TF_IN_AUTOMATION = "true"

        TF_PLAN_NAME = "tfplan"

        PLAN_BUCKET = "terraform-plan-artifacts-ruthvijay"
    }

    stages {

        stage('Checkout') {

            steps {

                cleanWs()

                checkout scm
            }
        }

        stage('Terraform Format Check') {

            steps {

                sh 'terraform fmt -check -recursive'
            }
        }

        stage('Terraform Init') {

            steps {

                dir("environments/${params.ENV}") {

                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Validate') {

            steps {

                dir("environments/${params.ENV}") {

                    sh 'terraform validate'
                }
            }
        }

        stage('TFLint') {

            steps {

                dir("environments/${params.ENV}") {

                    sh 'tflint'
                }
            }
        }

        stage('tfsec Scan') {

            steps {

                dir("environments/${params.ENV}") {

                    sh 'tfsec .'
                }
            }
        }

        stage('Checkov Scan') {

            steps {

                dir("environments/${params.ENV}") {

                    sh 'checkov -d .'
                }
            }
        }

        stage('Terraform Plan') {

            steps {

                dir("environments/${params.ENV}") {

                    sh """
                    terraform plan \
                    -out=${TF_PLAN_NAME}
                    """
                }
            }
        }

        stage('Archive tfplan') {

            steps {

                archiveArtifacts(
                    artifacts: "environments/${params.ENV}/${TF_PLAN_NAME}",
                    fingerprint: true
                )
            }
        }

        stage('Upload tfplan to S3') {

            steps {

                sh """
                aws s3 cp \
                environments/${params.ENV}/${TF_PLAN_NAME} \
                s3://${PLAN_BUCKET}/${params.ENV}/build-${BUILD_NUMBER}-tfplan
                """
            }
        }

        stage('Approval for Stage') {

            when {

                expression {

                    params.ENV == "stage"
                }
            }

            steps {

                timeout(time: 30, unit: 'MINUTES') {

                    input(
                        message: "Approve STAGE deployment?"
                    )
                }
            }
        }

        stage('Approval for Production') {

            when {

                expression {

                    params.ENV == "prod"
                }
            }

            steps {

                timeout(time: 60, unit: 'MINUTES') {

                    input(
                        message: "Approve PROD deployment?"
                    )
                }
            }
        }

        stage('Terraform Apply') {

            steps {

                dir("environments/${params.ENV}") {

                    sh """
                    terraform apply \
                    -auto-approve \
                    ${TF_PLAN_NAME}
                    """
                }
            }
        }
    }

    post {

        always {

            cleanWs()
        }
    }
}
