const axios = require("axios");
const expect = require("chai").expect;
const dockerBridgeIP = "172.17.0.1";

describe("Tests to the \"/\" endpoint", () => {
    it("should return a 200 status code", async () => {
        const res = await axios(`http://${dockerBridgeIP}:80/`);
        expect(res.status).to.equal(200);
    });

    it("should return a JSON object with a Message", async () => {
        const res = await axios(`http://${dockerBridgeIP}:80/`);
        expect(res.data).to.haveOwnProperty("message");
    });

    it("should return a JSON object with a Timestamp", async () => {
        const res = await axios(`http://${dockerBridgeIP}:80/`);
        expect(res.data).to.haveOwnProperty("timestamp");
    });

    it("should return a Message saying \"My name is ...\"", async () => {
        const res = await axios(`http://${dockerBridgeIP}:80/`);
        expect(res.data.message).to.contain("My name is");
    });

    it("should return a UNIX style timestamp (numerical values only)", async () => {
        const res = await axios(`http://${dockerBridgeIP}:80/`);
        expect(res.data.timestamp).to.be.a("number");
    });
    it("timestamp should be within a few seconds of now", async () => {
        const res = await axios(`http://${dockerBridgeIP}:80/`);
        // Check if the timestamp is within 5 seconds of the current time
        const now = Date.now();
        expect(res.data.timestamp).to.be.within(now - 5000, now);
    });
});
