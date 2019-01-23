package gossip.handlers;

import gossip.agent.MessageSender;
import gossip.config.FileConfig;
import gossip.messages.DataMessage;
import gossip.messages.MessageCreator;
import gossip.messages.MessageType;
import gossip.peers.PeerNode;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

import ballerina.net.InetAddress;

import static gossip.config.Config.DefaultValues.DEFAULT_LISTEN_PORT;
import static gossip.config.Config.KeyNames.LISTEN_PORT;
import static gossip.messages.MessageType.ACK;
import static org.hamcrest.CoreMatchers.is;
import static org.junit.Assert.assertThat;
import static org.mockito.Matchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@RunWith(MockitoJUnitRunner.class)
public class PingHandlerTest {

    public static final int SOURCE_PORT = 9023;
    public static final int DESTINATION_PORT = 8182;
    private PingHandler pingHandler;

    @Mock
    MessageSender sender;

    @Mock
    FileConfig config;

    @Mock
    InetAddress mockAddress;

    @Mock
    MessageCreator messageCreator;

    @Captor
    ArgumentCaptor<DataMessage> messageCaptor;

    @Mock
    DataMessage mockDataMessage;

    PeerNode currentNode;

    PeerNode peerNode;

    @Before
    public void setUp() {
        this.pingHandler = new PingHandler(sender, messageCreator);
        when(config.getValue(LISTEN_PORT, DEFAULT_LISTEN_PORT)).thenReturn(DESTINATION_PORT);
        when(messageCreator.ackResponseForPingMsg(any(DataMessage.class))).thenReturn(mockDataMessage);
    }

    @Test
    public void shouldResponseWithAnAckMessage() throws Exception {
        String sequenceNumber = "1234";
        DataMessage message = new DataMessage(sequenceNumber, peerNode, MessageType.PING, currentNode);
        this.pingHandler.handle(message);

        verify(sender).send(messageCaptor.capture());
        DataMessage interceptedMessage = messageCaptor.getValue();

        assertThat(interceptedMessage, is(mockDataMessage));
    }
}
