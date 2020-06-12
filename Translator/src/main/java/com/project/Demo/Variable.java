package com.project.Demo;

public class Variable {
	private String type;
	private String name;
	private String value;
	private String contract;

	public Variable(String type, String name, String value, String contract) {
		this.type = type;
		this.name = name;
		this.value = value;
		this.contract = contract;
	}
	
	public Variable(String type, String name) {
		this(type, name, null, null);
	}

	public Variable(String type, String name, String contract) {
		this(type, name, null, contract);
	}
	
	public String getContract() {
		return contract;
	}

	public void setContract(String contract) {
		this.contract = contract;
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

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((name == null) ? 0 : name.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Variable other = (Variable) obj;
		if (name == null) {
			if (other.name != null)
				return false;
		} else if (!name.equals(other.name))
			return false;
		return true;
	}
}
