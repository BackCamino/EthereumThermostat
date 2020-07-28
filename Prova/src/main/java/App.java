import javax.bluetooth.DiscoveryAgent;
import javax.bluetooth.LocalDevice;
import javax.bluetooth.RemoteDevice;
import java.io.IOException;
public class App {
    public static void main(String[] args) throws IOException {
        LocalDevice device = LocalDevice.getLocalDevice();
        RemoteDevice remoteDevice[]=device.getDiscoveryAgent().retrieveDevices(DiscoveryAgent.PREKNOWN);
        for(RemoteDevice d : remoteDevice)
        {
            System.out.println("Device Name : "+d.getFriendlyName(false));
            System.out.println("Bluetooth Address : "+d.getBluetoothAddress()+"\n");
        }
    }
}