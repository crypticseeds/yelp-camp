pipeline {
    agent {
        node {
            label 'agent'
        }
    }
    tools {
        nodejs 'NodeJS'
        dockerTool 'docker'
    }
    stages {
        stage ('Git Checkout') {
            steps {
                git branch: 'main', credentialsId: 'git-cred', url: 'https://github.com/crypticseeds/yelp-camp.git'
            }
        }
        stage ('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }
        stage ('Run Tests') {
            steps {
                sh 'npm test'
            }
        }
        stage ('Trivy fs Scan') {
            steps {
                sh 'trivy fs --format table -o fs-report.html .' 
            }
        }
        stage ('Sonaqube Scan') {
            steps {
                script {
                    def scannerHome = tool 'sonar-scanner' 
                    withSonarQubeEnv('sonar') {
                        sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=yelp-camp -Dsonar.projectName=yelp-camp -Dsonar.sources=."
                    }
                }
            }
        }
        stage ('Build Docker Image & Tag') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred') {
                        sh """
                            docker build -t crypticseeds/yelp-camp:latest -t crypticseeds/yelp-camp:v1.${BUILD_NUMBER} .
                        """
                    }
                }
            }
        }
        stage ('Trivy Image Scan') {
            steps {
                sh 'trivy image --format table --scanners vuln -o image-report.html crypticseeds/yelp-camp:latest'
            }
        }
        stage ('Push Docker Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred') {
                        sh """
                            docker push crypticseeds/yelp-camp:latest
                            docker push crypticseeds/yelp-camp:v1.${BUILD_NUMBER}
                        """
                    }
                }
            }
        }
    }
}
