Kafka
  |
  | order message
  v
Consumer.cs
  |
  | understands the message using demo.proto
  v
Entities.cs
  |
  | saves order data
  v
PostgreSQL






.csproj       = project setup
Program.cs    = starts the service
Consumer.cs   = does the main work
Entities.cs   = describes data
.proto        = describes message format
Dockerfile    = packages the service
README.md     = explains the service





1. What language/runtime does my service use?
dot.net /.NET Runtime   Microsoft.NET.Sdk
2. What base image do I need?
mcr.microsoft.com/dotnet/sdk
3. Where should my code live inside the container?
/app
4. What dependencies do I need to install?
```sh
make generate-protobuf
```

Navigate back to `src/accounting` and execute:

```sh
dotnet build
```
5. Which port does my service use?
noport
6. What command starts my service?
nothing 
lets build it locally 



programming lang
version
