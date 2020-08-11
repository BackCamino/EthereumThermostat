import com.github.BackCamino.EthereumThermostat.bpmn2sol.soliditycomponents.*;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

class SolidityFileTest {
    @Test
    void basicFileTest() {
        SolidityFile sf = new SolidityFile("File");
        System.out.println(sf.print());
        assertEquals("// SPDX-License-Identifier: UNLICENSED\npragma SOLIDITY ^0.6.10;", sf.print());
    }

    @Test
    void complexFileTest() {
        SolidityFile sf = new SolidityFile("Contract");
        Contract c = new Contract("Contract");
        c.addAttribute(new Variable("variable1", new Type(Type.BaseTypes.INT)));
        c.addAttribute(new Variable("v2", new Type("type1")));
        c.addEvent(new Event("event1"));
        c.addEvent(new Event("event2", List.of(new Variable("vName", new Type("tName")))));
        c.addExtended(new Contract("Co2"));
        c.addFunction(new Function("f1"));
        Function f2 = new Function("f2");
        Modifier m1 = new Modifier("m1");
        f2.addModifier(m1, new Value("v111"), new Value("v222"));
        c.addFunction(f2);
        c.addModifier(m1);
        sf.addComponent(c);
        System.out.println(sf.print());
        //assertEquals("// SPDX-License-Identifier: UNLICENSED\npragma SOLIDITY ^0.6.10;", sf.print());
    }
}