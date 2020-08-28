import com.github.EmmanueleBollino.solcraft.soliditycomponents.*;
import com.github.EmmanueleBollino.solcraft.standardizedcomponents.OwnedContract;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

public class StandardizedComponentsTest {
    @Test
    public void OwnedContractTest() {
        Contract oc = new OwnedContract();
        System.out.println(oc.print());
    }
}
