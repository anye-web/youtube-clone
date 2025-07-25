pipeline{
    agent any
    tools{
        jdk 'jdk17'
        nodejs 'nodejs'
    }

    environment{
        SCANNER_HOME=tool 'sonar-scanner'
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

        stage('OWASP Dependency-Check Vulnerabilities') {
            steps {
                dependencyCheck additionalArguments: ''' 
                            -o './'
                            -s './'
                            -f 'ALL' 
                            --prettyPrint''', odcInstallation: 'DP-Check'
                
                dependencyCheckPublisher pattern: 'dependency-check-report.xml'
            }
        }

          stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
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
                sh 'docker run -d --name youtube-clone-v${BUILD_NUMBER} -p 3000:3000 janohjr/youtube-clone:latest'
            }
        }

        stage('TRIVY'){
            steps{
                sh "trivy image janohjr/youtube-clone:latest > trivyimage.txt"
            }
        }

    }

    post{
        success {
            slackSend(channel: '#devopps', color: 'good', message: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL}) was successful."  )
        }
        failure {
            slackSend(channel: '#devopps', color: 'danger', message: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL}) failed."  )
        }
        always {
            echo 'build finished, check slack for notifications.'
        }
    }
}

// squ_d2e0afa4d194e616466aff63ccd6cdc4674b9e5b