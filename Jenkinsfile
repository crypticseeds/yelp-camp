pipeline {
    agent {
        node {
            label 'do-agent'
        }
    }
    tools {
        nodejs 'node22'
        dockerTool 'docker'
    }
    environment {
        CLOUDINARY_CLOUD_NAME = credentials('CLOUDINARY_CLOUD_NAME')
        CLOUDINARY_KEY = credentials('CLOUDINARY_KEY')
        CLOUDINARY_SECRET = credentials('CLOUDINARY_SECRET')
        MAPBOX_TOKEN = credentials('MAPBOX_TOKEN')
        DB_URL = credentials('DB_URL')
        SECRET = credentials('SECRET')
    }
    stages {
        stage ('Git Checkout') {
            steps {
                git branch: 'main', credentialsId: 'github', url: 'https://github.com/crypticseeds/yelp-camp.git'
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
                    withSonarQubeEnv('sonarqube') {
                        sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=yelp-camp -Dsonar.projectName=yelp-camp -Dsonar.sources=."
                    }
                }
            }
        }
        stage ('Build Docker Image & Tag') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'dockerhub') {
                        withCredentials([
                            string(credentialsId: 'CLOUDINARY_CLOUD_NAME', variable: 'CLOUDINARY_CLOUD_NAME'),
                            string(credentialsId: 'CLOUDINARY_KEY', variable: 'CLOUDINARY_KEY'),
                            string(credentialsId: 'CLOUDINARY_SECRET', variable: 'CLOUDINARY_SECRET'),
                            string(credentialsId: 'MAPBOX_TOKEN', variable: 'MAPBOX_TOKEN'),
                            string(credentialsId: 'DB_URL', variable: 'DB_URL'),
                            string(credentialsId: 'SECRET', variable: 'SECRET')
                        ])  {
                            sh """
                                docker build \
                                --build-arg CLOUDINARY_CLOUD_NAME=$CLOUDINARY_CLOUD_NAME \
                                --build-arg CLOUDINARY_KEY=$CLOUDINARY_KEY \
                                --build-arg CLOUDINARY_SECRET=$CLOUDINARY_SECRET \
                                --build-arg MAPBOX_TOKEN=$MAPBOX_TOKEN \
                                --build-arg DB_URL=$DB_URL \
                                --build-arg SECRET=$SECRET \
                                -t crypticseeds/yelp-camp:latest .
                                """
                        }
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
                    withDockerRegistry(credentialsId: 'dockerhub') {
                        sh "docker push crypticseeds/yelp-camp:latest"
                    }
                }
            }
        }
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
        
    }
}
