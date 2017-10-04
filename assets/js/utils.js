function are_items_not_wrapped(item, index, items) {
	if(index > 0) {
		const current_item = item.getBoundingClientRect();
		const previous_item = items[index-1].getBoundingClientRect();
		return current_item.top === previous_item.top;
	}
	return true;
}

function do_hide_on_flex_wrap(items, to_hide) {
	const result = items.every(are_items_not_wrapped);
	$(to_hide).toggleClass('hidden', result);
}

function hide_on_flex_wrap(items_selector, to_hide_selector) {
	const item_nodes = document.querySelectorAll(items_selector);
	const items = Array.from(item_nodes);
	const to_hide = document.querySelector(to_hide_selector);

	do_hide_on_flex_wrap(items, to_hide);
	$(window).resize(() => do_hide_on_flex_wrap(items, to_hide));
}


export {
	hide_on_flex_wrap
}
