package gossip.handlers;

import gossip.agent.MessageSender;
import gossip.config.FileConfig;
import gossip.messages.MessageCreator;
import gossip.messages.MessageType;
import gossip.peers.MembershipList;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

import static org.junit.Assert.*;

@RunWith(MockitoJUnitRunner.class)
public class MessageTypeRegistryTest {

    private MessageTypeRegistry messageTypeRegistry;

    @Mock
    private MembershipList membershipList;

    @Mock
    private MessageSender sender;

    @Mock
    private FileConfig config;

    @Mock
    private MessageCreator messageCreator;

    @Before
    public void setUp() {
        messageTypeRegistry = new MessageTypeRegistry(sender, config, membershipList, messageCreator);
    }

    @Test
    public void shouldReturnJoinHandler() {
        Handler handler = messageTypeRegistry.handlerForType(MessageType.JOIN);

        assertTrue(handler instanceof JoinHandler);
    }

    @Test
    public void shouldReturnPingHandler() {
        Handler handler = messageTypeRegistry.handlerForType(MessageType.PING);

        assertTrue(handler instanceof PingHandler);
    }

    @Test
    public void shouldReturnPingAckHandler() {
        Handler handler = messageTypeRegistry.handlerForType(MessageType.ACK);

        assertTrue(handler instanceof AckHandler);
    }
}
