const core = require('@actions/core');
const github = require('@actions/github');
const Mocha = require('mocha')
const fs = require('fs');
const path = require('path');

const fail = (message) => {
    core.setFailed(message);
    process.exit(1);
};

(async () => {
    try { 
        const mocha = new Mocha();
        const testDir = 'tests/'

        fs.readdirSync(testDir)
            .filter(file => {
                return path.extname(file) === '.js'
            })
            .forEach(file => {
                mocha.addFile(path.join(testDir, file))
            })

        mocha.run( failures => {
            fail('Unable to run tests')
        })
    } catch (error) {
        fail(`Error validating app: ${error.stack}`);
    }
})();
