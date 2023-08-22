node {
    environment {
        CI = 'true'
        DEPLOY_APPROVED = 'false' // Shared environment variable
    }
    stage('Build') {
        docker.image('python:2-alpine').inside {
            sh 'python -m py_compile sources/add2vals.py sources/calc.py'
            stash name: 'compiled-results', includes: 'sources/*.py*'
        }
    }
    
    stage('Test') {
        docker.image('qnib/pytest').inside {
            sh 'py.test --verbose --junit-xml test-reports/results.xml sources/test_calc.py'
        }
        junit 'test-reports/results.xml'
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
        dir("${BUILD_ID}") {
            unstash 'compiled-results'
            def VOLUME = "${pwd()}/sources:/src"
            def IMAGE = 'cdrx/pyinstaller-linux:python2'
            
            sh "docker run --rm -v ${VOLUME} ${IMAGE} 'pyinstaller -F add2vals.py'"
            
            archiveArtifacts artifacts: "${BUILD_ID}/sources/dist/add2vals", allowEmptyArchive: true
            sh "docker run --rm -v ${VOLUME} ${IMAGE} 'rm -rf build dist'"
        }
    }
}
