const add = require('../scripts/add')

test('adds numbers', () => {
    expect(add(2, 3)).toBe(5);
});