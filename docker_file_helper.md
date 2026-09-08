to make a docker file with unfamilier lanugues question you should as 

1.How is the language installed?
is there any pre build image of this lanuage 
determine which vesion is req

2. Is it a "Compiled" or "Interpreted" language?Understanding how the language runs dictates how heavy your Docker image will be:If it's Compiled (like Go, Rust, Mojo): You can compile the code on your computer first, then just COPY the single executable file into a lightweight Linux image (like alpine or ubuntu). You don't even need to install the new language inside Docker!If it's Interpreted (like Python, Ruby) or uses a VM (like Java): You must install the entire language runtime inside the Docker image so it can read and execute your source code files on the fly
3. 3. How does it handle dependencies?Almost every microservice relies on external libraries or packages.Figure out the name of the new language’s package manager (similar to npm for Node or pip for Python).Copy only the dependency configuration file first, run the install command, and then copy the rest of your code. This ensures Docker caches your libraries so you don't waste time downloading them every single time you edit a line of code.

4. What port does it listen on?Microservices must communicate with the outside world.Look at the configuration files or documentation of the microservice to see which network port it binds to (e.g., 8080, 3000, 5000).You must match this port in your EXPOSE command inside the Dockerfile, and again when you use the docker run -p command to start the container.