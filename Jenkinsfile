pipeline {

    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    parameters {
        choice(
            name: 'ENV',
            choices: ['dev', 'stage', 'prod'],
            description: 'Select Environment'
        )
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                dir("environments/${params.ENV}") {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Format Check') {
            steps {
                dir("environments/${params.ENV}") {
                    sh 'terraform fmt -check'
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
                    sh 'tflint || true'
                }
            }
        }

        stage('Tfsec Security Scan') {
            steps {
                dir("environments/${params.ENV}") {
                    sh 'tfsec . || true'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("environments/${params.ENV}") {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Manual Approval') {
            steps {
                input message: "Approve Terraform Apply for ${params.ENV}?"
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("environments/${params.ENV}") {
                    sh 'terraform apply -auto-approve tfplan'
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
