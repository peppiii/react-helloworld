pipeline {
    agent {
        node {
            label 'master'
            customWorkspace "workspace/${env.BRANCH_NAME}/src/github.com/peppiii/react-helloworld"
        }
    }
    environment {
        SERVICE = 'react-helloworld'
    }
    stages {
        stage('Checkout') {
            when {
                anyOf { branch 'master'; branch 'develop'; branch 'staging' }
            }
            steps {
                echo 'Checking out from Git'
                checkout scm
            }
        }
        stage('Build') {
            parallel {
                stage('Code review') {
                    environment {
                        scannerHome = tool 'sonarQubeScanner'
                    }
                    when {
                        branch 'develop'
                    }
                    steps {
                        withSonarQubeEnv('sonarQube') {
                            sh "${scannerHome}/bin/sonar-scanner"
                        }
                        timeout(time: 5, unit: 'MINUTES') {
                            waitForQualityGate abortPipeline: true
                        }
                    }
                }
                stage('Build and Deploy') {
                    environment {
                        branch = "${env.BRANCH_NAME}"
                    }
                    stages {
                        stage('Deploy to development') {
                            when {
                                branch 'develop'
                            }
                            steps {
                                sh 'chmod +x build.sh'
                                sh './build.sh $branch'
                            }
                        }
                        stage('Deploy to staging') {
                            when {
                                branch 'staging'
                            }
                            steps {
                                sh 'chmod +x build.sh'
                                sh './build.sh $branch'
                            }
                        }
                        stage('Deploy to production') {
                            when {
                                branch 'master'
                            }
                            steps {
                                sh 'chmod +x build.sh'
                                sh './build.sh $branch'
                            }
                        }
                    }
                    post {
                       success {
                           slackSend color: '#00FF00', message: "Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} SUCCESS (<${env.BUILD_URL}|Open>)"
                       }
                       failure {
                           slackSend color: '#FF0000', message: "Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} FAILED (<${env.BUILD_URL}|Open>)"
                       }
                    }
                }
            }
        }
    }
}
