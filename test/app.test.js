const request = require('supertest');
const app = require('../app');

describe('GET /planets', () => {
  it('should return 200', async () => {
    const res = await request(app).get('/planets');
    expect(res.statusCode).toEqual(200);
  });
});
