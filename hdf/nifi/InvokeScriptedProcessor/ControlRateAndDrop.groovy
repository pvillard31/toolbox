class ControlRateAndDrop implements Processor {

    def REL_SUCCESS = new Relationship.Builder()
            .name('signal')
            .description('One flow file will be routed to this relationship according to the given frequency')
            .build();

    def REL_DROP = new Relationship.Builder()
            .name('drop')
            .description('Every other flow file will be routed to this relationship')
            .build();

    def FREQUENCY = new PropertyDescriptor.Builder()
            .name('Frequency')
            .description('Frequency used to release one flow file in the success relationship')
            .required(true)
            .addValidator(StandardValidators.TIME_PERIOD_VALIDATOR)
            .build();

    def lastSignal = 0L;

    @Override
    void initialize(ProcessorInitializationContext context) { }

    @Override
    Set<Relationship> getRelationships() { return [REL_SUCCESS, REL_DROP] as Set }

    @Override
    Collection<ValidationResult> validate(ValidationContext context) { return null }

    @Override
    PropertyDescriptor getPropertyDescriptor(String name) {
        switch(name) {
            case 'Frequency': return FREQUENCY
            default: return null
        }
    }

    @Override
    void onPropertyModified(PropertyDescriptor descriptor, String oldValue, String newValue) { }

    @Override
    List<PropertyDescriptor> getPropertyDescriptors() { return [FREQUENCY] as List }

    @Override
    String getIdentifier() { return 'ControlRateAndDrop-InvokeScriptedProcessor' }

    @Override
    void onTrigger(ProcessContext context, ProcessSessionFactory sessionFactory) throws ProcessException {
      try {

        def session = sessionFactory.createSession()
        def flowFile = session.get()
        if (flowFile == null) {
            return
        }

        def freq = context.getProperty(FREQUENCY).asTimePeriod(java.util.concurrent.TimeUnit.MILLISECONDS).longValue();

        if(new Date().getTime() - lastSignal > freq) {
          session.transfer(flowFile, REL_SUCCESS)
          session.commit()
          lastSignal = new Date().getTime()
        } else {
          session.transfer(flowFile, REL_DROP)
          session.commit()
        }

      } catch(e) {
          throw new ProcessException(e)
      }
    }

}

processor = new ControlRateAndDrop()
