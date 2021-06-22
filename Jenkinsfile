pipeline {
    agent any
    environment {
        DOCKER_IMAGE_NAME = "purwar/hello_world_app"
    }
    
    stages {
        stage('Build Docker Image') {
            when {
                branch 'main'
            }
            steps {
                script {
                    app = docker.build(DOCKER_IMAGE_NAME)
                    app.inside {
                        sh 'echo $(curl localhost:8080)'
                    }
                }
            }
        }
        stage('Push Docker Image') {
            when {
                branch 'main'
            }
            steps {
                script {
                    withCredentials([usernamePassword( credentialsId: 'docker_hub_login', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        usr = USERNAME
		              	pswd = PASSWORD
                    }
                    docker.withRegistry('','docker_hub_login') {
                        sh "docker login -u ${usr} -p ${pswd}"
                        app.push("${env.BUILD_NUMBER}")
                        app.push("latest")
                    }
                }
            }
        }
      
        stage('Canary Deployment') {
            when {
                branch 'main'
            }
            environment { 
                CANARY_REPLICAS = 1
            }
            steps {
                kubernetesDeploy(
                    kubeconfigId: 'kubeconfig',
                    configs: 'Deployment-canary.yaml',
                    enableConfigSubstitution: true
                )
            }
        }        
  
        stage('Application Deployment') {
            when {
                branch 'main'
            }
            environment { 
                CANARY_REPLICAS = 0
            }
            steps {
                input 'Deploy to Prod?'
                milestone(1)
                kubernetesDeploy(
                    kubeconfigId: 'kubeconfig',
                    configs: 'Deployment-canary.yaml',
                    enableConfigSubstitution: true
                )
                kubernetesDeploy(
                    kubeconfigId: 'kubeconfig',
                    configs: 'Deployment.yaml',
                    enableConfigSubstitution: true
                )
            }
        }
        
    }
}
