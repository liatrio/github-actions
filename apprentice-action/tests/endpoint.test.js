const axios = require('axios');
const core = require('@actions/core');
const expect = require('chai').expect

describe('Tests to the "/" endpoint', () => {
    it('should return a 200 status code', done => {
        axios('http://localhost:80/').then(res => {
            console.log('test')
            console.log(res);
            expect(res.statusCode).to.be(200)
        })
        done();
    });

    it('should return a JSON object with a Message', done => {
        axios('http://localhost:80/').then(res => {
            expect(res.data).to.haveOwnProperty('Message');
        })
        done();
    })

    it('should return a JSON object with a Timestamp', done => {
        axios('http://localhost:80/').then(res => {
            expect(res.data).to.haveOwnProperty('Timestamp');
        })
        done();
    })

    it('should return a Message saying "My name is ..."', done => {
        axios('http://localhost:80/').then(res => {
            expect(res.data.Message).to.contain('My name is');
        })
        done();
    })

    it('should return a UNIX style timestamp (numerical values only)', done => {
        axios('http://localhost:80/').then(res => {
            expect(res.data.Timestamp).to.not.be.NaN();
        })
        done();
    })
});
