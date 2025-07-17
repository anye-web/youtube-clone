pipeline{
    agent any
    tools{
        jdk 'jdk17'
        nodejs 'nodejs'
    }

    stages {

        stage('clean workspace'){
            steps{
                cleanWs()
            }
        }

        stage('Clean workspace'){
            steps{
                git branch: 'main', url: 'https://github.com/anye-web/youtube-clone.git'
            }
        }

        stage('Install Dependencies'){
            steps{
                sh "npm install"
            }
        }
        stage('Docker Build & push'){
            steps{
                script{
                    withDockerRegistry(credentialsId: 'docker'){
                        sh "docker build -t youtube-clone ."
                        sh "docker tag youtube-clone janohjr/youtube-clone:latest"
                        sh "docker push janohjr/youtube-clone:latest"
                    }
                }
            }
        }

        stage('Deploy to container'){
            steps{
                sh 'docker run -d --name youtube-clone -p 3000:3000 janohjr/youtube-clone:latest'
            }
        }

    }
}