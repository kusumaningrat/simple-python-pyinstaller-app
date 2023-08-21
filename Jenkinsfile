// Declarative Pipeline
pipeline {
    agent any
    try {
        stages {
            stage('Build') {
                agent {
                    docker {
                        image 'python:2-alpine'
                    }
                }
                steps {
                    sh 'python -m py_compile sources/add2vals.py sources/calc.py'
                }
            }
            stage('Test') {
                agent {
                    docker {
                        image 'qnib/pytest'
                    }
                }
                steps {
                    sh 'py.test --verbose --junit-xml test-reports/results.xml sources/test_calc.py'
                }
                post {
                    always {
                        junit 'test-reports/results.xml'
                    }
                }
            }
            stage('Manual Approval') {
                steps {
                    script {
                        def userInput = input(
                            message: 'Lanjutkan ke tahap deploy? (Click "Proceed" to continue)',
                            parameters: [
                                [$class: 'ChoiceParameterDefinition', 
                                choices: 'Proceed\nAbort', 
                                description: 'Select an option',
                                name: 'ACTION']
                            ]
                        )
                        
                        if (userInput == 'Proceed') {
                            echo 'Continuing to Deploy stage'
                            DEPLOY_APPROVED = 'true' // Set the environment variable
                        } else {
                            echo 'Aborting the pipeline'
                            currentBuild.result = 'ABORTED'
                            error('Pipeline aborted by user')
                        }
                        echo "DEPLOY_APPROVED: ${DEPLOY_APPROVED}"
                    }
                }
            }
            stage('Deploy') {
                when {
                    expression { return env.DEPLOY_APPROVED }
                }
                agent {
                    docker {
                        image 'cdrx/pyinstaller-linux:python2'
                    }
                }
                steps {
                    sh 'pyinstaller --onefile sources/add2vals.py'
                }
                post {
                    success {
                        archiveArtifacts 'dist/add2vals'
                        sshagent(credentials: ['devauth']) {
                            sh """
                                scp -r dist ubuntu@54.179.75.188:/home/ubuntu
                            """
                        }
                        sleep(time: 60, unit: 'SECONDS')
                    }
                }
            }
        }
    } catch (Exception e) {
        currentBuild.result = 'FAILURE'
        throw e
    }
}


// // Scripted Pipeline
// node {
//     try {
//         stage('Build') {
//             docker.image('python:3.11.4-alpine3.18').inside {
//                 sh 'python -m py_compile sources/add2vals.py sources/calc.py'
//             }
//         }

//         stage('Test') {
//             docker.image('qnib/pytest').inside {
//                 sh 'py.test --verbose --junit-xml test-reports/results.xml sources/test_calc.py'
//             }
//             junit 'test-reports/results.xml'
//         }
//     } catch (Exception e) {
//         currentBuild.result = 'FAILURE'
//         throw e
//     }
// }