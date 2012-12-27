----
title: Intro to Python Asynchronous Programming and Twisted's Deferreds
----

#Intro to Python Asynchronous Programming and Twisted's Deferreds#

##A Mad Hatter##

Imagine that a madman (we'll call him MadHatter) walks up to you and
thrusts into your hand a FireCracker.  The FireCracker's internal Fuse is
burning and will explode the firework in the next few seconds.
We will model this scenario using Asynchronous Python code.  This sort  of
task is exactly what Twisted excels at, and we will write a Twisted
implementation of the scenario at the end of the article.  Before that,
however, we will examine what components the task makes necessary in a
general async event manager.  To this end we shall create our own event
manager called Fate (don't worry, this will be very bare bones to fit in a
few lines of code, yet suitable for the task we have set it).  You may have
noticed that the pieces of the system I have described so far have names
fitting into a real-life analogy.  This is a device to aid memory and
understanding; I will make clear as we consider each part whether it is
specific to our scenario, or applicable to a more general class of
circumstances.  Hopefully the choice of naming will be helpful - Twisted
also has interesting names, but ones which strangely have very little to do
with the function of their bearers (see Conch, Manhole and Jelly). 
Enter the actors:

    class FireCracker(object):
        def __init__(self, owner):
            self.owner = owner
        def hand_to(self, new_owner):
            self.owner = new_owner
        def explode(self):
            print "BOOM! Firecracker exploded in the unlucky hands " \
                "of {0}".format(self.owner)
    class MadHatter(object):
        pass
    class BenEills(object):
        pass

We've got this far using only the 'standard' everyday sort of Python.  No
async magic.
Now, why is an event manager useful?  Why not simply continue in this vein?
Well, we want to be able to simulate the burning fuse.  Let's add a
light_fuse() method to FireCracker.  In naïve, synchronous Python we could
do something like this:

    def light_fuse(self):
        burning_time = random.choice([0.5, 1.0, 1.5, 2.0])
        time.sleep(burning_time)
        self.explode()

Do not do this!  Why?  There are two obvious issues:

* While burning the FireCracker() cannot be handed to anyone else.  The MadHatter()'s dark designs will never be realized because directly after lighting the fuse the processor becomes completely taken up with sleeping.  The path of execution effectively sits at the time.sleep() statement for several seconds, after which it moves to the next line, exploding in the lighter's own hands.  There is simply no way to do anything between the two consecutive lines of code.

* Secondly, if you have more than one FireCracker(), or indeed anything else in your model, it will all unhelpfully freeze for several seconds.  Only one thing can possibly be happening at a particular time.  This is the fundamental limitation of traditional synchronous programming.

We shall now find a way around this by writing Fate() async code to use it.
In general, asynchronous programming could be summarized by replacing any
blocking operation (e.g. sleeping, waiting for data on sockets, waiting or
external command to return) with special event-handling commands.  By
writing Fate, we will see that the blocking, clunky operations are in fact
moved back behind the scenes into the event framework, which intelligently
combines them to give the illusion of simultaneous happenings.  They are
merely being 'switched between'.  (Incidentally, this is similar to the way
that modern operating systems allow you to run multiple applications at
once by rapidly switching between them behind-the-scenes).

##Fate##

  On to Fate.  We have to provide a way for the developer working on the
FireCracker code to 'set' events.  The simplest method of doing this is
perhaps timer-based events.  Lets make a Fuse class that represents a timed
event.  Just follow along, you'll see precisely how it fits together with
everything else in a bit.

    class Fuse(object):
        def set_time(self, time):
            self.time = time
        def is_burned(self):
            return self.time < time.time()

So, this is simple.  We get a fuse, set the burning time and then we can
check in the future whether or not it is fully burned.  It is a trifle
whether to use '<' or '<=' - it is incredibly unlikely that this will make
any difference in your Python implementation, due to the high precision of
the Standard Library's time() call.  I have opted for the nicer-looking
version, avoiding the perhaps philosophical issue of subdivision of time.
Now, the way that this will be incorporated into our code is as follows:

* We will create Fate and add to it a get_fuse() method.  This will take a single argument of the (floating point) number of seconds representing burning time.  It will add this to the current time, giving the absolute time at which the fuse will be fully burned, creates a Fuse instance and sets the time on it.  It saves this to internal instance memory and returns it.

* We will add a light_fuse() method to FireCracker.  This will get a Fuse using Fate.get_fuse() and tell it what to do when the fuse is fully burned.  It will do this by simply calling its set_handler() method with self.explode.  We are telling Fate how to handle the fuse being completely burned.

But wait.  Fuse doesn't have a set_handler() method.  We're going to fix
that presently, it was simply more convenient to present the material in
this logical order.
The following is the whole of Fate, including the slightly expanded Fuse
class.  It will be explained afterwards.  Try to glean the rough
functionality from the source.

    class Fate(object):
        def __init__(self):
            self._shutdown = False
            self.fuses = []
        def get_fuse(self, seconds):
            f = Fuse()
            f.set_time(time.time() + seconds)
            self.fuses.append(f)
            return f
        def check_fuses(self):
            for fuse in self.fuses:
                if fuse.has_handler() and fuse.is_burned():
                    self.fuses.remove(fuse)
                    fuse.call_handler()
        def run(self):
            while not self._shutdown:
                self.check_fuses()
                time.sleep(0.2)
        def shutdown(self):
            self._shutdown = True
    class Fuse(object):
        def set_time(self, time):
            self.time = time
        def is_burned(self):
            return self.time < time.time()
        def set_handler(self, handler):
            self.handler = handler
        def has_handler(self):
            return hasattr(self, 'handler')
        def call_handler(self):
            self.handler()

Whew!  Now the explanation:

1. check_fuses() goes through every fuse in the instance memory (which should be every fuse if the other developers have behaved and used get_fuse() rather than instantiating Fuse for themselves).  For each fuse it checks is the fuse has_handler() and is_burned().  If so, it removes the fuse from memory and calls the handler.  If the fuse is still burning, or no handler has been set, it simply is left in the list to be tested again.
2. run() is the 3-line meat of Fate and our whole event management system.  Every 0.2 seconds it runs check_fuses() until it detects a system shutdown event.
3. The set_handler function accepts a function.  In case you're not familiar with passing around functions as arguments, you simply supply the function name; this is the equivalent in C-derived languages of a function pointer, and, internally to Python, is represented as such.  This function is what you want to be called when the fuse is fully burned.
4. has _ handler() and call _ handler() are straightforward.
5. shutdown() tells Fate that we wish to stop handling events, causing run() to return and our program to terminate.
The pattern of writing a program using Fate is easy:
6. You do whatever initialization you want
7. You set up at least one initial Fuse with handlers
8. You call Fate's run()
9. The initial handlers can themselves set up subsequent handlers
10. All actual work is done in these handler functions
11. Eventually, some handler calls Fate's shutdown() method
12. This causes run() to return and, after any of our own shutdown code, the program exits.

Now, we'll fill in the bits of the FireCracker scenario to make use of
Fate.  This will be a good example of how to use Fate for other
applications, and, more generally, is illustrative of a standard
asynchronous design pattern.  Remember that we're replacing the bad,
synchronous version one of our light_fuse() method with a better Fate-ful
one.

Here is the complete FireCracker program, minus general-purpose Fate code
and imports.

    class FireCracker(object):
        def __init__(self, owner, fate):
            self.owner = owner
            self.fate = fate
        def hand_to(self, new_owner):
            self.owner = new_owner
        def explode(self):
            print "BOOM! Firecracker exploded in the unlucky hands " \
                "of {0}".format(self.owner)
            # After any explosion, shutdown program after 2 second delay
            # Otherwise we'd have to kill the program
            f = self.fate.get_fuse(2)
            f.set_handler(self.fate.shutdown)
        def light_fuse(self):
            burning_time = random.choice([0.5, 1.0, 1.5, 2.0])
            f = self.fate.get_fuse(burning_time)
            f.set_handler(self.explode)
    class MadHatter(object):
        def __repr__(self):
            return "Mad Hatter"
    class BenEills(object):
        def __repr__(self):
            return "Ben Eills"
    # Universe come into existence
    fate = Fate()
    # Hatter and Ben are born
    hatter = MadHatter()
    ben = BenEills()
    # FireCracker appears, intitially owned by the Hatter
    fc = FireCracker(hatter, fate)
    # The Hatter lights the fuse
    fc.light_fuse()
    # And hands it to Ben
    fc.hand_to(ben)
    # Universe begins paying attention to duration of time
    # At some point during run, the FireCracker will explode
    #   and 2 seconds later, Fate will be shutdown
    fate.run()
    # Universe has ended.  We have no cleanup to do.

##Taking Fate to its limits##

  Now, our Fate system functions well at the limited tasks set out for it.
It will not do any of the following things:

* Allow a Fuse to be lit which is burned only after receiving a particular packet over the network
* Allow multiple users to handle any one Fuse (the last to call set_handler() is always the sole "owner")
* Utilise more complicated mechanisms to check for Fuses being completely burned.
* e.g. using the low-level select() call to avoid processor-intensive polling every 0.2 seconds

Let's see a quick second example that takes Fate to the limits of its
functionality.

    ## This function explodes Parliament and shuts down universe.
    def explode_parliament():
        print "Boom! The Houses of Parliament explode!"
        fate.shutdown()
    ## This class represents a fuse in part of a chain.
    import sys
    class FuseInChain(object):
        def __init__(self, tie_to, burn_time):
            """
            Initialize a new fuse in our chain, tying it to the current end
            fuse, tie_to
            If tie_to is None, we are tied directly to the barrel.
            We become the new end fuse.
            """
            self.next = tie_to
            self.burn_time = burn_time
        def ignite(self):
            """
            Ignite this fuse.
            """
            print "...igniting next fuse in chain..."
            f = fate.get_fuse(self.burn_time)
            if self.next is None:
                # We are the last Fuse in the chain.  Blow up barrel.
                f.set_handler(explode_parliament)
            else:
                f.set_handler(self.next.ignite)
    fate = Fate()
    tmp = FuseInChain(None, 0.3)
    for i in xrange(7):
        tmp = FuseInChain(tmp, i/10.0)
    last = tmp
    last.ignite()
    fate.run()

Here we have represented a chain of fuses by putting in the "user" code a
chaining mechanism: the handler for one Fuse() i.e. ignite() itself creates
another fuse.
Try following through the "logical flow" of execution through the program. 
It can be more difficult to follow this than standard, synchronous code,
but we gain an advantage when working on any non-trivial program that must
accomplish multiple tasks in some sort of concurrency.
Now that we've written an event handler and two examples together, its time
to introduce Twisted.  It is similar to Fate, but much more extensible.
Twisted also contains many utility modules for doing things like HTTP
downloading and executing external commands.

##Twisted##

  To get started with Twisted, remember these two approximations:

* "Twisted Reactor" is approximately "Fate", and
* "Deferred" is approximately "Fuse"

Here is a simple Twisted program, adapted from the [Twisted Docs]:
    from twisted.internet import reactor, defer

    def slow_multiply(x, y):
        """
        This function multiplies two numbers very slowly (for a computer).
        It takes 3 seconds.
        It returns a Deferred instantly which fires with the result once
        we've determined it.
        """
        d = defer.Deferred()
        reactor.callLater(3, d.callback, x * y)
        return d
    def print_multiplication_result(fired_value):
        """
        Is called by Twisted when the Deferred given by slow_multiply finally
        fires.  We pretty print the result it fires with.
        """
        print "... result is {0}!".format(fired_value)
    print "Determining result of 5 * 7..."
    d = slow_multiply(5, 7)
    d.addCallback(print_multiplication_result)
    # We stop Twisted after 4 seconds, long enough for our code to finish.
    # This is pretty similar to Fate's "shutdown" method.
    reactor.callLater(4, reactor.stop)
    reactor.run()

So, similarly to our Fuse, a Deferred is Twisted's indication that the
returner will fire it at some point in the future.
The slow-multiply function returns the Deferred instantly, but uses
Twisted's callLater function to call the "callback" method
of its Deferred in 3 seconds.  This simulates a slow multiplier.
Instead of adding a "handler", we add a "callback" function to the
Deferred.  In this case it's printData() which as to deal with whatever
value the Deferred fires with.
With these small difference in mind, it ought to be easy for you to rewrite
the Mad Hatter example using Twisted.  Here is is:

    # Standard Twisted imports.  You'll need these for most Twisted
    applications.
    from twisted.internet import reactor, defer
    import random
    class FireCracker(object):
        def __init__(self, owner):
            self.owner = owner
        def hand_to(self, new_owner):
            self.owner = new_owner
        def explode(self, rv):
            print "BOOM! Firecracker exploded in the unlucky hands " \
                "of {0}".format(self.owner)
        def light_fuse(self):
            burning_time = random.choice([0.5, 1.0, 1.5, 2.0])
            d = defer.Deferred()
            d.addCallback(self.explode)
            reactor.callLater(burning_time, d.callback, True)
    class MadHatter(object):
        def __repr__(self):
            return "Mad Hatter"
    class BenEills(object):
        def __repr__(self):
            return "Ben Eills"
    # Hatter and Ben are born
    hatter = MadHatter()
    ben = BenEills()
    # FireCracker appears, initially owned by the Hatter
    fc = FireCracker(hatter)
    # The Hatter lights the fuse immediately
    reactor.callLater(0, fc.light_fuse)
    # Waits one second and passes it to Ben
    reactor.callLater(1, fc.hand_to, ben)
    # And shutdown Twisted after 3 seconds, long enough for the FireCracker
    to certainly explode
    reactor.callLater(3, reactor.stop)
    # Start Twisted
    reactor.run()

We've made this one more interesting: it may explode in the MadHatter's own
hands.
The single-letter "d" is commonly used to point to a Deferred object within
Twisted programs.  This convention can make it easier to keep clear which
returned values are actual data (i.e. non-Deferred objects) and which are
simply "promises of data" (i.e. Deferreds).

  [Twisted Docs]: http://twistedmatrix.com/documents/current/core/howto/defer.html#auto1


##Beyond this tutorial##

  The above should be enough to get you started working within the Twisted
asynchronous framework, and you should have a reasonably clear idea of how
events fit together.  With such programming, you have the advantage of not
having to worry about simultaneous variable access and other issues
associated with threaded programming, but you have the additional
responsibility of making your functions return fast (no "block" for long
periods of time).  Looking at Fate its clear why this would be a problem:
your code would stop the event handler looking for other events that need
to happen.
It is for this reason that the other parts of the Twisted framework become
desirable.  In synchronous programming, one might use

    urllib2.urlopen("http://www.beneills.com/").read(1000)

to read a web page.  This would be bad in Twisted, because while the
standard library is occupied with downloading it (which might take several
seconds), anything else that ought to run couldn't.
The correct Twisted way to do this is:

    from twisted.internet import reactor
    import twisted.web.client as twc
    Example of using Twisted's getPage utility function in place of urllib2#
    This Twisted library function returns a Deferred
    d = twc.getPage("http://www.beneills.com/")
    # The deferred will fire when/if the page is successfully downloaded with
    the contents of the web page as a string
    # As in the above examples, we tell Twisted what to do when it does fire
    def printPage(data):
        print "Page contents:"
        print data
    d.addCallback(printPage)
    # Shutdown, regardless of success after 3 seconds
    reactor.callLater(3, reactor.stop)
    reactor.run()

Internally, Twisted's getPage function downloads small chunks of the page
at a time, allowing other events to be handled during downloading.
Two important topics not covered here for reasons of brevity are errbacks
and deferred chaining.
Errbacks are the counterpart to callbacks that are meant to be triggered in
the event of something going wrong in a function.  They are similar to
exceptions, and can be handled with the addErrback method of a Deferred.
Chaining is a way to link Deferreds "end-to-end" in a chain, so that one
will only fire after another does.  This allows us to do the "line-by-line"
execution that is given to us for free in synchronous programming.  Also
useful is the inlineCallbacks generator, which performs a similar function.
As a closing remark, it is important to choose correctly when asynchronous
code is necessary and when it is not.  For simple shell-replacement Python
scripts it is clearly an overkill, but for applications performing multiple
network requests or handling user input while doing background work Twisted
is probably the answer.

##Resources##

  * [All Examples in a Compressed Archive]
* [Official Twisted Deferred Guide]
* [Deferred Object API Reference]
* [GitHub Repository with Development Version of this Tutorial]

  [All Examples in a Compressed Archive]: http://www.beneills.com/tutorials/deferreds/examples.tar.gz
[Official Twisted Deferred Guide]: http://twistedmatrix.com/documents/current/core/howto/defer.html
[Deferred Object API Reference]: http://twistedmatrix.com/documents/12.2.0/api/twisted.internet.defer.Deferred.html
[GitHub Repository with Development Version of this Tutorial]: https://github.com/beneills/deferreds
