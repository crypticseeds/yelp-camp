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
                git branch: 'main', credentialsId: 'git-cred', url: 'https://github.com/crypticseeds/ibm-interview.git'
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
                sh 'trivy fs --format table -o fs-report.html .'  // Fixing the typo
            }
        }
        stage ('Sonaqube Scan') {
            steps {
                script {
                    def scannerHome = tool 'sonar-scanner'  // Moved this into a script block
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
                        sh "docker build -t crypticseeds/yelp-camp:latest ."
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
                        sh "docker push crypticseeds/yelp-camp:latest"
                    }
                }
            }
        }
        /*
        stage ('Deploy to EKS') {
            steps {
                    withKubeCredentials(kubectlCredentials: [[caCertificate: '', clusterName: 'main-eks-cluster', contextName: '', credentialsId: 'k8-token', namespace: 'yelp-camp', serverUrl: 'https://59AD44BC10B2CE5C401C68B206DA8A53.gr7.eu-west-2.eks.amazonaws.com']]) {
                        sh "kubectl apply -f Manifests/yelp-camp-deployment.yaml"
                        sleep 30
                }
            }
        }
        stage ('Verify Deployment') {
            steps {
                    withKubeCredentials(kubectlCredentials: [[caCertificate: '', clusterName: 'main-eks-cluster', contextName: '', credentialsId: 'k8-token', namespace: 'yelp-camp', serverUrl: 'https://59AD44BC10B2CE5C401C68B206DA8A53.gr7.eu-west-2.eks.amazonaws.com']]) {
                        sh "kubectl get pods -n yelp-camp"
                        sh "kubectl get pods -n yelp-camp"
                }
            }
        }
        */
        
    }
}
