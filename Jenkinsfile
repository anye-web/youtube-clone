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

        stage('Sonarqube Analysis'){
            steps{
                withSonarQubeEnv('sonar-server'){
                    sh '''
                        $SCANNER_HOME/bin/sonar-scanner \
                            -Dsonar.projectKey=youtube-clone \
                            -Dsonar.sources=. \
                            -Dsonar.host.url=http://34.207.89.7:9000 \
                            -Dsonar.token=sqp_ef9ca55b74399574a602840c98ca89df718a6658   
                    '''
                }
            }
        }

        stage('Quality Gate'){
            steps{
                script{
                    waitForQualityGate abortPipline: false, credentialsId: 'sonar-token'
                }
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
                            --prettyPrint''', odcInstallation: 'OWASP Dependency-Check'
                
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
                sh 'docker run -d --name youtube-clone -p 3000:3000 janohjr/youtube-clone:latest'
            }
        }

        stage('TRIVY'){
            steps{
                sh "trivy image janohjr/youtube-clone:latest > trivyimage.txt"
            }
        }

    }
}

// squ_d2e0afa4d194e616466aff63ccd6cdc4674b9e5b