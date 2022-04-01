const axios = require("axios");
const expect = require("chai").expect;

describe("Tests to the \"/\" endpoint", () => {
    it("should return a 200 status code", async () => {
        const res = await axios("http://host.docker.internal:80/");
        expect(res.status).to.equal(200);
    });

    it("should return a JSON object with a Message", async () => {
        const res = await axios("http://host.docker.internal:80/");
        expect(res.data).to.haveOwnProperty("message");
    });

    it("should return a JSON object with a Timestamp", async () => {
        const res = await axios("http://host.docker.internal:80/");
        expect(res.data).to.haveOwnProperty("timestamp");
    });

    it("should return a Message saying \"My name is ...\"", async () => {
        const res = await axios("http://host.docker.internal:80/");
        expect(res.data.Message).to.contain("My name is");
    });

    it("should return a UNIX style timestamp (numerical values only)", async () => {
        const res = await axios("http://host.docker.internal:80/");
        expect(res.data.timestamp).to.be.a("number");
    });
});
