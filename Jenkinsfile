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
            docker.image('cdrx/pyinstaller-linux:python3').inside {
                sh 'pyinstaller --onefile sources/add2vals.py'
            }
            archiveArtifacts 'dist/add2vals'
        }
    } catch (Exception e) {
        currentBuild.result = 'FAILURE'
        throw e
    }

}