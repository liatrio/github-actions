const axios = require('axios');
const core = require('@actions/core');
const expect = require('chai').expect

describe('Tests to the "/" endpoint', () => {
    it('should return a 200 status code', async () => {
        const res = await axios('http://localhost:80/') 
        expect(res.statusCode).to.be(200)
    });

    it('should return a JSON object with a Message', async () => {
        const res = await axios('http://localhost:80/')
        expect(res.data).to.haveOwnProperty('Message');
    })

    it('should return a JSON object with a Timestamp', async () => {
        const res = await axios('http://localhost:80/')
        expect(res.data).to.haveOwnProperty('Timestamp');
    })

    it('should return a Message saying "My name is ..."', async () => {
        const res = await axios('http://localhost:80/')
        expect(res.data.Message).to.contain('My name is');
    })

    it('should return a UNIX style timestamp (numerical values only)', async () => {
        const res = await axios('http://localhost:80/')
        expect(res.data.Timestamp).to.not.be.NaN();
    })
});    