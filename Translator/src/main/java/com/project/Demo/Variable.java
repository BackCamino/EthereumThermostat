package com.project.Demo;

public class Variable {
	private String type;
	private String name;
	private String value;

	public Variable(String type, String name, String value) {
		this.type = type;
		this.name = name;
		this.value = value;
	}

	public Variable(String type, String name) {
		this(type, name, null);
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getValue() {
		return value;
	}

	public void setValue(String value) {
		this.value = value;
	}
}
