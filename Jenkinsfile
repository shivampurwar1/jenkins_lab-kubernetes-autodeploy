pipeline {
    agent any
    environment {
        DOCKER_IMAGE_NAME = "purwar/hello_world_app"
	CANARY_REPLICAS = 0
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
	    
        stage('Smoke Testing') {
            when {
                branch 'main'
            }
            steps {
                script {
                    sleep (time: 5)
                    def response = httpRequest (
                        url: "http://$KUBE_MASTER_IP:8081/",
                        timeout: 30
                    )
                    if (response.status != 200) {
                        error("Smoke test failed against the canary deployment.")
                    }
                }
            }
        }
	    
        stage('Application Deployment') {
            when {
                branch 'main'
            }
            steps {
                milestone(1)
                kubernetesDeploy(
                    kubeconfigId: 'kubeconfig',
                    configs: 'Deployment.yaml',
                    enableConfigSubstitution: true
                )
            }
        }
        
    }
	
    post {
        cleanup {
            kubernetesDeploy (
                kubeconfigId: 'kubeconfig',
                configs: 'Deployment-canary.yaml',
                enableConfigSubstitution: true
            )
        }
    }
	
}
