// const String geminiApiKey = 'AIzaSyCE8f0WawjSUAh5aRIAhsyQsqGa8vvoeNE';
// const String geminiModel = 'gemini-1.5-flash';
const String geminiApiKey = 'AIzaSyCE8f0WawjSUAh5aRIAhsyQsqGa8vvoeNE';

// Primary model (quota friendly)
const String geminiPrimaryModel = 'gemini-2.0-flash-lite';

// Optional fallback models if primary hits 429/quota
const List<String> geminiFallbackModels = [
  'gemini-2.0-flash',
  'gemini-flash-lite-latest',
  'gemini-flash-latest',
];