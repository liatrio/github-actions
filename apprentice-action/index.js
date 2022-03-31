const core = require('@actions/core');
const github = require('@actions/github');
const Mocha = require('mocha')
const fs = require('fs');
const util = require('util')
const path = require('path');

const fail = (message) => {
    core.setFailed(message);
    process.exit(1);
};

(async () => {
    try { 
        const readdir = util.promisify(fs.readdir)
        const mocha = new Mocha();
        const testDir = 'tests/'
        const files = await readdir(testDir)

        files
            .filter(file => {
                return path.extname(file) === '.js'
            })
            .forEach(file => {
                mocha.addFile(path.join(testDir, file))
            })

        mocha.run( failures => {
            if(failures) {
                fail("Tests resulted in failures... Make sure you're running your app on port 80")
            }
        })
    } catch (error) {
        fail(`Error validating app: ${error.stack}`);
    }
})();
