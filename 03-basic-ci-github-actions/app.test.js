const request = require('supertest');
const app = require('./app');

describe('Dockerized Node.js App', () => {
  describe('GET /', () => {
    it('should return 200 status code', async () => {
      const response = await request(app).get('/');
      expect(response.status).toBe(200);
    });

    it('should return correct message', async () => {
      const response = await request(app).get('/');
      expect(response.body.message).toBe('Hello from Your Dockerized App!');
    });

    it('should return JSON content type', async () => {
      const response = await request(app).get('/');
      expect(response.headers['content-type']).toMatch(/json/);
    });

    it('should include version and timestamp', async () => {
      const response = await request(app).get('/');
      expect(response.body).toHaveProperty('version');
      expect(response.body).toHaveProperty('timestamp');
      expect(response.body.version).toBe('1.0.0');
    });
  });

  describe('GET /health', () => {
    it('should return 200 status code', async () => {
      const response = await request(app).get('/health');
      expect(response.status).toBe(200);
    });

    it('should return healthy status', async () => {
      const response = await request(app).get('/health');
      expect(response.body.status).toBe('healthy');
    });

    it('should include uptime and timestamp', async () => {
      const response = await request(app).get('/health');
      expect(response.body).toHaveProperty('uptime');
      expect(response.body).toHaveProperty('timestamp');
      expect(typeof response.body.uptime).toBe('number');
    });
  });

  describe('Error handling', () => {
    it('should return 404 for non-existent routes', async () => {
      const response = await request(app).get('/non-existent-route');
      expect(response.status).toBe(404);
    });
  });
});
