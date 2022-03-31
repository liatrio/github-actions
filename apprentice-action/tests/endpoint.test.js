const axios = require('axios');
const core = require('@actions/core');
const expect = require('chai').expect

const res = axios(`http://localhost:${core.input('app_port')}/`)

describe('Tests to the "/" endpoint', () => {
    it('should return a 200 status code', done => {
        expect(res.statusCode).to.be(200)
        done();
    });

    it('should return a JSON object with a Message', done => {
        expect(res.data).to.haveOwnProperty('Message');
        done();
    })

    it('should return a JSON object with a Timestamp', done => {
        expect(res.data).to.haveOwnProperty('Timestamp');
        done();
    })

    it('should return a Message saying "My name is ..."', done => {
        expect(res.data.Message).to.contain('My name is');
        done();
    })

    it('should return a UNIX style timestamp (numerical values only)', done => {
        expect(res.data.Timestamp).to.not.be.NaN();
        done();
    })
});