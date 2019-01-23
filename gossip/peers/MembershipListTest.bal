package gossip.peers;

import gossip.config.Config;
import gossip.config.FileConfig;
import gossip.dissemination.EventGenerator;
import gossip.dissemination.EventLOg;
import org.junit.Before;
import org.junit.Test;


import ballerina.net.InetAddress;
import ballerina.net.UnknownHostException;

import ballerina.net.jms;
import org.wso2.ballerina.connectors.nodes;
import ballerina.lang.jsons;
import ballerina.lang.messages;
import ballerina.lang.system;
import ballerina.lang.exceptions;



service MembershiplistTestService{
 
    public final int LESS_THAN_WAIT_THRESHOLD_MILLIS := 1;
    public final int PAST_WAIT_THRESHOLD_MILLIS := 80;
    public final int NO_RECORDS := 0;
    private MembershipList membershipList;

    private Config config;
    private EventGenerator eventGenerator;
    
     @Before
    public void setUp() throws Exception {
        this.config = new FileConfig();
        this.eventGenerator = new EventGenerator(new EventLog(config));
        this.membershipList = new MembershipList(config, eventGenerator);
    }

    private void registerNMemberNodes() throws UnknownHostException {
        this.membershipList = new MembershipList(config, eventGenerator);
        this.membershipList.add(buildTestNode(0));
        this.membershipList.add(buildTestNode(1));
        this.membershipList.add(buildTestNode(2));
        this.membershipList.add(buildTestNode(3));
        this.membershipList.add(buildTestNode(4));
        this.membershipList.add(buildTestNode(5));
        this.membershipList.add(buildTestNode(6));
        this.membershipList.add(buildTestNode(7));
        this.membershipList.add(buildTestNode(8));
        this.membershipList.add(buildTestNode(9));
     }

       private PeerNode buildTestNode(int i) throws UnknownHostException {
        return new PeerNode(InetAddress.getByName("127.0.0.1"), Integer.valueOf(834 + "" + i));
    }

    @Test
    public void shouldReturnTheCountOfMembers() throws Exception {
        registerNMemberNodes();

        assertThat(membershipList.memberCount(), is(10));
    }

    @Test
    public void shouldReturnNullWhenNoNodesAreRegistered() throws Exception {
        List<PeerNode> peerNodes = this.membershipList.selectNodesRandomly(2);

     assertThat(peerNodes.size(), is(0));
    }

    @Test
    public void shouldBeAbleToRandomlySelectAndReturnNNodes() throws Exception {
        registerNMemberNodes();
        List<PeerNode> selectNodes = this.membershipList.selectNodesRandomly(3);

        assertThat(selectNodes.size(), is(3));
    }

     @Test
    public void shouldNotReturnNodeAwaitingForAckIfWaitThresholdIsNotPast() throws Exception {
        registerNMemberNodes();
        PeerNode peerNode = this.membershipList.selectNodesRandomly(1).get(0);
        peerNode.pingInitiated();

        sleep(LESS_THAN_WAIT_THRESHOLD_MILLIS);

        List<PeerNode> nodesAwaitingAck = this.membershipList.getNodesAwaitingAck();
        assertThat(nodesAwaitingAck.size(), is(NO_RECORDS));
    }
    
    @Test
    public void shouldReturnNodeAwaitingForAckIfWaitThresholdIsPast() throws Exception {
        registerNMemberNodes();
        PeerNode peerNode = this.membershipList.selectNodesRandomly(1).get(0);
        peerNode.pingInitiated();

        sleep(PAST_WAIT_THRESHOLD_MILLIS);

         List<PeerNode> nodesAwaitingAck = this.membershipList.getNodesAwaitingAck();
        assertThat(nodesAwaitingAck.size(), is(1));
        assertThat(nodesAwaitingAck.get(0), is(peerNode));
    }

    @Test
    public void shouldNotReturnNodeAwaitingForIndirectAckIfWaitThresholdIsNotPast() throws Exception {
        registerNMemberNodes();
        PeerNode peerNode = this.membershipList.selectNodesRandomly(2).get(0);
        peerNode.indirectPingInitiated();

        sleep(LESS_THAN_WAIT_THRESHOLD_MILLIS);

        List<PeerNode> nodesAwaitingIndirectAck = this.membershipList.getNodesAwaitingIndirectAck();
        assertThat(nodesAwaitingIndirectAck.size(), is(NO_RECORDS));
    } 

    @Test
    public void shouldMoveANodeOutOfFailureSuspectListWhenMarkedDead() throws Exception {
        registerNMemberNodes();
        PeerNode peerNode = this.membershipList.selectNodesRandomly(2).get(0);
        peerNode.markSuspect();

        sleep(LESS_THAN_WAIT_THRESHOLD_MILLIS);
        peerNode.markDead();

        sleep(PAST_WAIT_THRESHOLD_MILLIS);

        List<PeerNode> nodesMarkedAsSuspects = this.membershipList.getNodesMarkedAsSuspect();
        assertThat(nodesMarkedAsSuspects.size(), is(NO_RECORDS));
    }
}
    
 
