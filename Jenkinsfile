pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "us-east-1"
        TF_DIR = "terraform"   // Directory containing main.tf
        SSH_KEY = "ec2-ssh-key" // Jenkins credential ID for SSH private key
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/your-username/your-repo.git'
            }
        }

        stage('Provision EC2 with Terraform') {
            steps {
                dir(TF_DIR) {
                    sh '''
                        terraform init
                        terraform apply -auto-approve
                    '''
                    script {
                        // Capture EC2 IP
                        env.EC2_HOST = sh(
                            script: "terraform output -raw public_ip",
                            returnStdout: true
                        ).trim()
                        echo "EC2 Public IP: ${env.EC2_HOST}"
                    }
                }
            }
        }

        stage('Deploy index.html to EC2') {
            steps {
                sshagent([SSH_KEY]) {
                    sh '''
                        # Install Nginx
                        ssh -o StrictHostKeyChecking=no ubuntu@$EC2_HOST "sudo apt update -y && sudo apt install -y nginx"

                        # Copy index.html
                        scp -o StrictHostKeyChecking=no index.html ubuntu@$EC2_HOST:/tmp/index.html

                        # Move file to Nginx web root
                        ssh -o StrictHostKeyChecking=no ubuntu@$EC2_HOST "sudo mv /tmp/index.html /var/www/html/index.html && sudo systemctl restart nginx"
                    '''
                }
            }
        }
    }
}
