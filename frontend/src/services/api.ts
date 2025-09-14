
import axios from 'axios';

// Use a unique, easy-to-find placeholder
const baseURL = '__REACT_APP_API_URL__';

axios.defaults.baseURL = baseURL;
axios.defaults.headers.common['Content-Type'] = 'application/json';

// Export the base URL for direct fetch usage
export const API_BASE_URL = baseURL;

export default axios;


