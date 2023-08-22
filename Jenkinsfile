node {
    try {
        stage('Build') {
            docker.image('python:3.11.4-alpine3.18').inside {
                sh 'python -m py_compile sources/add2vals.py sources/calc.py'
                stash(name: 'compiled-results', includes: 'sources/*.py*')
            }
        }

        stage('Test') {
            docker.image('qnib/pytest').inside {
                sh 'py.test --verbose --junitxml=test-reports/results.xml sources/test_calc.py'
            }
            junit 'test-reports/results.xml'
        }
        
        stage('Deploy') {
            def VOLUME = "${pwd()}/sources:/src"
            def IMAGE = 'cdrx/pyinstaller-linux:python3'
            
            try {
                // Execute steps within the Docker container
                dir("${pwd()}") {
                    unstash(name: 'compiled-results')
                    sh 'ls -l'
                    sh "docker run --rm -v ${VOLUME} ${IMAGE} 'pyinstaller --onefile sources/add2vals.py'"
                }
                sleep(time: 60, unit: 'SECONDS')
            } catch (Exception e) {
                currentBuild.result = 'FAILURE'
                throw e
            }
        }
    } catch (Exception e) {
        currentBuild.result = 'FAILURE'
        throw e
    }
}
