pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "me-central-1"
        TF_DIR = "terraform"   // Directory containing main.tf
        SSH_KEY = "aws-ec2-key" // Jenkins credential ID for SSH private key
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "📦 Checking out code from GitHub..."
                git branch: 'main', url: 'https://github.com/farhan2784/Jenkins-terraform-ec2-web.git'
            }
        }

        stage('Provision EC2 with Terraform') {
            steps {
                dir("${TF_DIR}") {
                    withAWS(credentials: 'aws-creds', region: "${AWS_DEFAULT_REGION}") {
                        sh '''
                            echo "🚀 Initializing Terraform..."
                            terraform init

                            echo "🧩 Applying Terraform to provision EC2 instance..."
                            terraform apply -auto-approve
                        '''
                    }
                    script {
                        // Capture EC2 Public IP
                        env.EC2_HOST = sh(
                            script: "terraform output -raw public_ip",
                            returnStdout: true
                        ).trim()
                        echo "🌍 EC2 Public IP: ${env.EC2_HOST}"
                    }
                }
            }
        }

        stage('Deploy index.html to EC2') {
            steps {
                sshagent([SSH_KEY]) {
                    sh '''
                        # Install Nginx and deploy HTML page
                        ssh -o StrictHostKeyChecking=no ubuntu@$EC2_HOST "sudo apt update -y && sudo apt install -y nginx"
                        scp -o StrictHostKeyChecking=no index.html ubuntu@$EC2_HOST:/tmp/index.html
                        ssh -o StrictHostKeyChecking=no ubuntu@$EC2_HOST "sudo mv /tmp/index.html /var/www/html/index.html && sudo systemctl restart nginx"
                    '''
                }
            }
        }
    }

    post {
        failure {
            echo "❌ Pipeline failed. Please check Jenkins logs for details."
        }
        success {
            echo "✅ Deployment successful! Visit http://${env.EC2_HOST} to view your webpage."
        }
    }
}
