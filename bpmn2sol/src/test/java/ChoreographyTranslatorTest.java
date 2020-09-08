import com.github.BackCamino.EthereumThermostat.bpmn2sol.translators.ChoreographyTranslator;
import org.camunda.bpm.model.bpmn.Bpmn;
import org.camunda.bpm.model.bpmn.BpmnModelInstance;
import org.junit.jupiter.api.Test;

import java.io.File;

public class ChoreographyTranslatorTest {
    @Test
    void translationTest() {
        BpmnModelInstance model = Bpmn.readModelFromFile(new File("./diagram.bpmn"));
        ChoreographyTranslator translator = new ChoreographyTranslator(model);
        System.out.println(translator.translate().print());
    }
}