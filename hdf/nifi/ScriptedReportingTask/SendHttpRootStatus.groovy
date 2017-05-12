def json = Class.forName("javax.json.Json")
def httpClients = Class.forName("org.apache.http.impl.client.HttpClients")
def contentType = Class.forName("org.apache.http.entity.ContentType")

def status = context.getEventAccess().getControllerStatus();
def factory = json.createBuilderFactory(Collections.emptyMap());
def builder = factory.createObjectBuilder();

builder.add("componentId", status.getId());
builder.add("bytesRead", status.getBytesRead());
builder.add("bytesWritten", status.getBytesWritten());
builder.add("bytesReceived", status.getBytesReceived());
builder.add("bytesSent", status.getBytesSent());
builder.add("bytesTransferred", status.getBytesTransferred());
builder.add("flowFilesReceived", status.getFlowFilesReceived());
builder.add("flowFilesSent", status.getFlowFilesSent());
builder.add("flowFilesTransferred", status.getFlowFilesTransferred());
builder.add("inputContentSize", status.getInputContentSize());
builder.add("inputCount", status.getInputCount());
builder.add("outputContentSize", status.getOutputContentSize());
builder.add("outputCount", status.getOutputCount());
builder.add("queuedContentSize", status.getQueuedContentSize());
builder.add("activeThreadCount", status.getActiveThreadCount());
builder.add("queuedCount", status.getQueuedCount());

def requestEntity = new org.apache.http.entity.StringEntity(builder.build().toString(), contentType.APPLICATION_JSON);
def httpclient = httpClients.createDefault();
def postMethod = new org.apache.http.client.methods.HttpPost("http://localhost:9999/rootStatus");
postMethod.setEntity(requestEntity);
httpclient.execute(postMethod);
httpclient.close();
