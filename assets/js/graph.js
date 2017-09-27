import Chart from 'chart.js';
import axios from 'axios';

const ctx = document.getElementById('profile_graph');

function create_chart(info) {
	const chart = new Chart(ctx, {
		type: 'line',
		data: {
			labels: info.labels,
			datasets: [{
				borderColor: '#00bc8c',
				backgroundColor: 'rgba(66,255,139,0.1)',
				label: 'EHP',
				data: info.data
			}]
		},
		options: {}
	});
}

export default function get_graph(url) {
	axios.get(url)
		.then((response) => create_chart(response.data));
}
