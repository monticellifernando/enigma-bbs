/* jslint node: true */
'use strict';

var View			= require('./view.js').View;
var ansi			= require('./ansi_term.js');
var miscUtil		= require('./misc_util.js');
var util			= require('util');
var assert			= require('assert');

exports.MenuView	= MenuView;

function MenuView(client, options) {
	options.acceptsFocus = miscUtil.valueWithDefault(options.acceptsFocus, true);
	options.acceptsInput = miscUtil.valueWithDefault(options.acceptsInput, true);

	View.call(this, client, options);

	var self = this;

	if(this.options.items) {
		this.setItems(this.options.items);
	} else {
		this.items = [];
	}

	this.focusedItemIndex = this.options.focusedItemIndex || 0;
	this.focusedItemIndex = this.items.length >= this.focusedItemIndex ? this.focusedItemIndex : 0;

	this.itemSpacing	= this.options.itemSpacing || 1;
	this.itemSpacing	= parseInt(this.itemSpacing, 10);

	this.focusPrefix	= this.options.focusPrefix || '';
	this.focusSuffix	= this.options.focusSuffix || '';

	this.fillChar		= miscUtil.valueWithDefault(this.options.fillChar, ' ').substr(0, 1);
	this.justify		= this.options.justify || 'none';

	this.moveSelection = function(fromIndex, toIndex) {
		assert(!self.xPositionCacheExpired);
		assert(fromIndex >= 0 && fromIndex <= self.items.length);
		assert(toIndex >= 0 && toIndex <= self.items.length);

		self.items[fromIndex].focused	= false;
		self.drawItem(fromIndex);

		self.items[toIndex].focused 	= true;
		self.focusedItemIndex			= toIndex;
		self.drawItem(toIndex);
	};

	this.cachePositions = function() {
		//	:TODO: implement me!
	};

	this.drawItem = function(index) {
		//	:TODO: implement me!
	};
}

util.inherits(MenuView, View);

MenuView.prototype.redraw = function() {
	MenuView.super_.prototype.redraw.call(this);

	this.cachePositions();

	var count = this.items.length;
	for(var i = 0; i < count; ++i) {
		this.items[i].focused = this.focusedItemIndex === i;
		this.drawItem(i);
	}
};

MenuView.prototype.setItems = function(items) {
	var self = this;
	if(items) {	
		this.items = [];	//	:TODO: better way?
		items.forEach(function onItem(itemText) {
			self.items.push({
				text		: itemText,
				selected	: false,
			});
		});
	}
};

