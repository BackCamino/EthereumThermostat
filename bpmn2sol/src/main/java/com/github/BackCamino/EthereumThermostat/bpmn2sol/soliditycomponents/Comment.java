package com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents;

import java.util.Objects;

public class Comment implements SolidityComponent {
    private String comment;
    private boolean documentation;

    public Comment(String comment, boolean documentation) {
        Objects.requireNonNull(comment);
        this.comment = comment.trim();
        this.documentation = documentation;
    }

    public Comment(String comment) {
        this(comment, false);
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public boolean isDocumentation() {
        return documentation;
    }

    public void setDocumentation(boolean documentation) {
        this.documentation = documentation;
    }

    public void append(String comment) {
        this.comment = this.comment + comment.trim();
    }

    public void appendLine(String comment) {
        this.append("\n" + comment);
    }

    @Override
    public String print() {
        if (this.documentation)
            return "/**\n * "
                    + this.comment
                    .replace("*/", "")
                    .replace("\n", "\n * ")
                    + "\n */";

        if (!this.comment.contains("\n"))
            return "// " + this.comment;

        return "/* " + this.comment.replace("*/", "") + " */";
    }
}
