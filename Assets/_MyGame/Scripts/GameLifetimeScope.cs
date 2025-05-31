using MessagePipe;
using R3;
using UnityEngine;
using VContainer;
using VContainer.Unity;

namespace EasyMotherGame
{
    public class GameLifetimeScope : LifetimeScope
    {
        protected override void Configure(IContainerBuilder builder)
        {
            // RegisterMessagePipe returns options.
            var options = builder.RegisterMessagePipe(/* configure option */);

            // Setup GlobalMessagePipe to enable diagnostics window and global function
            builder.RegisterBuildCallback(c => GlobalMessagePipe.SetProvider(c.AsServiceProvider()));

            // RegisterMessageBroker: Register for IPublisher<T>/ISubscriber<T>, includes async and buffered.
            builder.RegisterMessageBroker<int>(options);

            // also exists RegisterMessageBroker<TKey, TMessage>, RegisterRequestHandler, RegisterAsyncRequestHandler

            // RegisterMessageHandlerFilter: Register for filter, also exists RegisterAsyncMessageHandlerFilter, Register(Async)RequestHandlerFilter
            //builder.RegisterMessageHandlerFilter<MyFilter<int>>();

            builder.RegisterEntryPoint<MessagePipeDemo>(Lifetime.Singleton);

        }
    }

    public class MessagePipeDemo : IStartable
    {
        readonly IPublisher<int> publisher;
        readonly ISubscriber<int> subscriber;

        public MessagePipeDemo(IPublisher<int> publisher, ISubscriber<int> subscriber)
        {
            this.publisher = publisher;
            this.subscriber = subscriber;
        }

        public void Start()
        {
            var d = MessagePipe.DisposableBag.CreateBuilder();
            subscriber.Subscribe(x => Debug.Log("S1:" + x)).AddTo(d);
            subscriber.Subscribe(x => Debug.Log("S2:" + x)).AddTo(d);

            Debug.Log("Publish 10");
            publisher.Publish(10);
            Debug.Log("Publish 20");
            publisher.Publish(20);
            Debug.Log("Publish 30");
            publisher.Publish(30);

            var disposable = d.Build();
            disposable.Dispose();
        }
    }
}
