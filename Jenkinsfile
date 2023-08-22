node {
    try {
        stage('Build') {
            docker.image('python:3.11.4-alpine3.18').inside {
                sh 'python -m py_compile sources/add2vals.py sources/calc.py'
            }
        }

        stage('Test') {
            docker.image('qnib/pytest').inside {
                sh 'py.test --verbose --junit-xml test-reports/results.xml sources/test_calc.py'
            }
            junit 'test-reports/results.xml'
        }
        
        stage('Deploy') {
            // Define the Docker agent
            def VOLUME = "${pwd()}/sources:/src"
            def IMAGE = 'cdrx/pyinstaller-linux:python2'

            // Set environment variables
            env.VOLUME = VOLUME
            env.IMAGE = IMAGE

            // Execute steps within the Docker container
            dir(path: env.BUILD_ID) {
                sh "cd ${pwd()} && ls"
                sh "docker run --rm -v ${VOLUME} ${IMAGE} 'pyinstaller -F add2vals.py'"
            }

            // Archive the artifacts
            archiveArtifacts "${env.BUILD_ID}/sources/dist/add2vals"

            // Cleanup build artifacts
            sh "docker run --rm -v ${VOLUME} ${IMAGE} 'rm -rf build dist'"
        }
    } catch (Exception e) {
        currentBuild.result = 'FAILURE'
        throw e
    }

}