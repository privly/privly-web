# This file contains all the record creation needed to seed the database with its default values.
#
# You should remove users from this file before running it on a production server.
#
# The data can be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# These share types are assumed to be present
#

identity_provider = IdentityProvider.new
identity_provider.name = "Privly Verified Email"
identity_provider.description = "The Privly Verified email is the email for the Privly user's account. Users must verify their email ownership with Privly"
identity_provider.save

identity_provider = IdentityProvider.new
identity_provider.name = "Privly Verified Domain"
identity_provider.description = "The Privly Verified domain is the domain for the Privly user's email account. Users must verify their email ownership with Privly"
identity_provider.save

identity_provider = IdentityProvider.new
identity_provider.name = "Password"
identity_provider.description = "The password is a secret that when sent with the request will add permissions on the content"
identity_provider.save

identity_provider = IdentityProvider.new
identity_provider.name = "IP Address"
identity_provider.description = "The IP address is where Privly requests originate"
identity_provider.save

#
# Production environments will want to customize records below this point
#
def get_password
  if Rails.env == "development"
    return "password"
  else
    abort("You should only run this on development.\naborting")
  end
end

# You should the emails if you don't want Sean to
# have an account on this server
development_user = User.find_by_email("development@priv.ly")
unless development_user
  password = get_password
  development_user = User.create(
    :email                  => 'development@priv.ly',
    :password               => password,
    :password_confirmation  => password
  )
  # Confirm the user for Devise
  development_user.confirm!
  development_user.can_post = true
  development_user.save
end

demonstration_user = User.find_by_email("demonstration@priv.ly")
unless demonstration_user
  password = get_password
  demonstration_user = User.create(
    :email                  => 'demonstration@priv.ly',
    :password               => password,
    :password_confirmation  => password
  )
  # Confirm the user for Devise
  demonstration_user.confirm!
  demonstration_user.can_post = true
  demonstration_user.save
end

admin_user = AdminUser.find_by_email("admin@priv.ly")
unless admin_user
  password = get_password
  admin_user = AdminUser.create(
    :email                  => 'admin@priv.ly',
    :password               => password,
    :password_confirmation  => password
  )
end

Post.create({:public => true, :content => '
Privly is a method for taking control of everything you share electronically. Facebook, Google, Twitter, and the rest do not own your data. You do.

By putting your content behind a link, and injecting it into the page on the browser side, your content is not subject to their terms. They can not even see it. Further, when we are done with our client side encryption library, even the place you store your content will not be able to read your content. Privly does not want your trust, we want to make Privly a protocol for connecting your life on the web.

**Privly Gives You**

* The ability to share/post/tweet/chat anywhere without giving the host site access to the content
* The power to grant and take away access to your content to anyone, anywhere
* The power to rewrite history, by changing the content behind the link

**<a href="https://priv.ly/pages/roadmap">Privly Will Give You</a>**

* The ability to share by email, aspect, circle, PGP key, List, geography, and other sharing methods
* Easy to use encrypted communications</li>
* And things we haven\'t thought of...yet

Privly has proven itself as a concept. You can use it on Facebook, Gmail, Google+, Twitter, Reddit, and just about anywhere else. As we refine the <a href="/pages/download">Firefox extension</a> and develop versions for other browsers, we hope you will check back. Sign up for an <a href="/invitations/new">invitation</a>, <a href="/pages/donate">donate</a>, or <a href="/pages/join">join us</a>!

'})

Post.create({:public => true, :content => 'SUCCESS'})

Post.create({:public => true, :content => '
# The Apology
## By Plato

How you have felt, O men of Athens, at hearing the speeches of my accusers, I cannot tell; but I know that their persuasive words almost made me forget who I was -- such was the effect of them; and yet they have hardly spoken a word of truth. But many as their falsehoods were, there was one of them which quite amazed me; -- I mean when they told you to be upon your guard, and not to let yourselves be deceived by the force of my eloquence. They ought to have been ashamed of saying this, because they were sure to be detected as soon as I opened my lips and displayed my deficiency; they certainly did appear to be most shameless in saying this, unless by the force of eloquence they mean the force of truth; for then I do indeed admit that I am eloquent.

But in how different a way from theirs! Well, as I was saying, they have hardly uttered a word, or not more than a word, of truth; but you shall hear from me the whole truth: not, however, delivered after their manner, in a set oration duly ornamented with words and phrases. No indeed! but I shall use the words and arguments which occur to me at the moment; for I am certain that this is right, and that at my time of life I ought not to be appearing before you, O men of Athens, in the chara cter of a juvenile orator -- let no one expect this of me. And I must beg of you to grant me one favor, which is this -- If you hear me using the same words in my defence which I have been in the habit of using, and which most of you may have heard in the a gora, and at the tables of the money-changers, or anywhere else, I would ask you not to be surprised at this, and not to interrupt me.

For I am more than seventy years of age, and this is the first time that I have ever appeared in a court of law, and I am quite a stranger to the ways of the place; and therefore I would have you regard me as if I were really a stranger, whom you would excuse if he spoke in his native tongue, and after the fashion of his country; -- that I think is not an unfair request. N ever mind the manner, which may or may not be good; but think only of the justice of my cause, and give heed to that: let the judge decide justly and the speaker speak truly.

And first, I have to reply to the older charges and to my first accusers, and then I will go to the later ones. For I have had many accusers, who accused me of old, and their false charges have continued during many years; and I am m ore afraid of them than of Anytus and his associates, who are dangerous, too, in their own way. But far more dangerous are these, who began when you were children, and took possession of your minds with their falsehoods, telling of one Socrates, a wise man, who speculated about the heaven above, and searched into the earth beneath, and made the worse appear the better cause. These are the accusers whom I dread; for they are the circulators of this rumor, and their hearers are too apt to fancy that specula tors of this sort do not believe in the gods. And they are many, and their charges against me are of ancient date, and they made them in days when you were impressible -- in childhood, or perhaps in youth -- and the cause when heard went by default, for the re was none to answer. And, hardest of all, their names I do not know and cannot tell; unless in the chance of a comic poet.

But the main body of these slanderers who from envy and malice have wrought upon you -- and there are some of them who are convince d themselves, and impart their convictions to others -- all these, I say, are most difficult to deal with; for I cannot have them up here, and examine them, and therefore I must simply fight with shadows in my own defence, and examine when there is no one who answers. I will ask you then to assume with me, as I was saying, that my opponents are of two kinds -- one recent, the other ancient; and I hope that you will see the propriety of my answering the latter first, for these accusations you heard long befo re the others, and much oftener.
  
[Read More](http://evans-experientialism.freewebspace.com/plato_apology.htm "Read More").
'})

Post.create({:public => true, :content => '
# Give Me Liberty Or Give Me Death
## By Patrick Henry

MR. PRESIDENT: It is natural to man to indulge in the illusions of hope. We are apt to shut our eyes against a painful truth -- and listen to the song of that siren, till she transforms us into beasts. Is this the part of wise men, engaged in a great and arduous struggle for liberty? Are we disposed to be of the number of those, who having eyes, see not, and having ears, hear not, the things which so nearly concern their temporal salvation? For my part, whatever anguish of spirit it may cost, I am willing to know the whole truth; to know the worst, and to provide for it.

I have but one lamp by which my feet are guided; and that is the lamp of experience. I know of no way of judging of the future but by the past. And judging by the past, I wish to know what there has been in the conduct of the British ministry for the last ten years, to justify those hopes with which gentlemen have been pleased to solace themselves and the house? Is it that insidious smile with which our petition has been lately received? Trust it not, sir; it will prove a snare to your feet. Suffer not yourselves to be betrayed with a kiss. Ask yourselves how this gracious reception of our petition comports with those warlike preparations which cover our waters and darken our land. Are fleets and armies necessary to a work of love and reconciliation? Have we shown ourselves so unwilling to be reconciled that force must be called in to win back our love? Let us not deceive ourselves, sir. These are the implements of war and subjugation -- the last arguments to which kings resort. I ask gentlemen, sir, what means this martial array, if its purpose be not to force us to submission? Can gentlemen assign any other possible motive for it? Has Great Britain any enemy in this quarter of the world, to call for all this accumulation of navies and armies? No, sir, she has none. They are meant for us: they can be meant for no other. They are sent over to bind and rivet upon us those chains which the British ministry have been so long forging. And what have we to oppose to them? Shall we try argument? Sir, we have been trying that for the last ten years. Have we anything new to offer upon the subject? Nothing. We have held the subject up in every light of which it is capable; but it has been all in vain. Shall we resort to entreaty and humble supplication? What terms shall we find which have not been already exhausted? Let us not, I beseech you, sir, deceive ourselves longer.

Sir, we have done everything that could be done to avert the storm which is now coming on. We have petitioned -- we have remonstrated -- we have supplicated -- we have prostrated ourselves before the throne, and have implored its interposition to arrest the tyrannical hands of the ministry and parliament. Our petitions have been slighted; our remonstrances have produced additional violence and insult; our supplications have been disregarded; and we have been spurned, with contempt, from the foot of the throne. In vain, after these things, may we indulge the fond hope of peace and reconciliation. There is no longer any room for hope. If we wish to be free -- if we mean to preserve inviolate those inestimable privileges for which we have been so long contending -- if we mean not basely to abandon the noble struggle in which we have been so long engaged, and which we have pledged ourselves never to abandon until the glorious object of our contest shall be obtained -- we must fight! -- I repeat it, sir, we must fight!! An appeal to arms and to the God of Hosts, is all that is left us!

They tell us, sir, that we are weak -- unable to cope with so formidable an adversary. But when shall we be stronger? Will it be the next week or the next year? Will it be when we are totally disarmed, and when a British guard shall be stationed in every house? Shall we gather strength by irresolution and inaction? Shall we acquire the means of effectual resistance by lying supinely on our backs, and hugging the delusive phantom of hope, until our enemies shall have bound us hand and foot? Sir, we are not weak, if we make a proper use of those means which the God of nature has placed in our power. Three millions of people, armed in the holy cause of liberty, and in such a country as that which we possess, are invincible by any force which our enemy can send against us. Besides, sir, we shall not fight our battles alone. There is a just God who presides over the destinies of nations; and who will raise up friends to fight our battles for us. The battle, sir, is not to the strong alone; it is to the vigilant, the active, the brave. Besides, sir, we have no election. If we were base enough to desire it, it is now too late to retire from the contest. There is no retreat but in submission and slavery! Our chains are forged. Their clanking may be heard on the plains of Boston! The war is inevitable and let it come!! I repeat it, sir, let it come!!!

It is in vain, sir, to extenuate the matter. Gentlemen may cry, peace, peace -- but there is no peace. The war is actually begun! The next gale that sweeps from the north will bring to our ears the clash of resounding arms! Our brethren are already in the field! Why stand we here idle? What is it that gentlemen wish? What would they have? Is life so dear, or peace so sweet, as to be purchased at the price of chains and slavery? Forbid it, Almighty God! -- I know not what course others may take; but as for me, give me liberty or give me death!  
'})

Post.create({:public => true, :content => '
# The Hypocrisy of American Slavery
## By Frederick Douglass

Fellow citizens, pardon me, and allow me to ask, why am I called upon to speak here today? What have I or those I represent to do with your national independence? Are the great principles of political freedom and of natural justice, embodied in that Declaration of Independence, extended to us? And am I, therefore, called upon to bring our humble offering to the national altar, and to confess the benefits, and express devout gratitude for the blessings resulting from your independence to us?

Would to God, both for your sakes and ours, that an affirmative answer could be truthfully returned to these questions. Then would my task be light, and my burden easy and delightful. For who is there so cold that a nation\'s sympathy could not warm him? Who so obdurate and dead to the claims of gratitude, that would not thankfully acknowledge such priceless benefits? Who so stolid and selfish that would not give his voice to swell the hallelujahs of a nation\'s jubilee, when the chains of servitude had been torn from his limbs? I am not that man. In a case like that, the dumb might eloquently speak, and the "lame man leap as an hart."

[Read More](http://www.historyplace.com/speeches/douglass.htm "Read More").
'})

Post.create({:public => true, :content => '
# The Gettysburg Address
## By Abraham Lincoln

Fourscore and seven years ago our fathers brought forth on this continent a new nation, conceived in liberty and dedicated to the proposition that all men are created equal.

Now we are engaged in a great civil war, testing whether that nation or any nation so conceived and so dedicated can long endure. We are met on a great battlefield of that war. We have come to dedicate a portion of that field as a final resting-place for those who here gave their lives that that nation might live. It is altogether fitting and proper that we should do this.

But, in a larger sense, we cannot dedicate, we cannot consecrate, we cannot hallow this ground. The brave men, living and dead who struggled here have consecrated it far above our poor power to add or detract. The world will little note nor long remember what we say here, but it can never forget what they did here. It is for us the living rather to be dedicated here to the unfinished work which they who fought here have thus far so nobly advanced. It is rather for us to be here dedicated to the great task remaining before us -- that from these honored dead we take increased devotion to that cause for which they gave the last full measure of devotion -- that we here highly resolve that these dead shall not have died in vain, that this nation under God shall have a new birth of freedom, and that government of the people, by the people, for the people shall not perish from the earth.
'})

Post.create({:public => true, :content => '
# Blood, Toil, Tears and Sweat

## May 13, 1940
## First Speech as Prime Minister to House of Commons

On May 10, 1940, Winston Churchill became Prime Minister. When he met his Cabinet on May 13 he told them that "I have nothing to offer but blood, toil, tears and sweat." He repeated that phrase later in the day when he asked the House of Commons for a vote of confidence in his new all-party government. The response of Labour was heart-warming; the Conservative reaction was luke-warm. They still really wanted Neville Chamberlain. For the first time, the people had hope but Churchill commented to General Ismay: "Poor people, poor people. They trust me, and I can give them nothing but disaster for quite a long time."

I beg to move,

That this House welcomes the formation of a Government representing the united and inflexible resolve of the nation to prosecute the war with Germany to a victorious conclusion.

On Friday evening last I received His Majesty\'s commission to form a new Administration. It as the evident wish and will of Parliament and the nation that this should be conceived on the broadest possible basis and that it should include all parties, both those who supported the late Government and also the parties of the Opposition. I have completed the most important part of this task. A War Cabinet has been formed of five Members, representing, with the Opposition Liberals, the unity of the nation. The three party Leaders have agreed to serve, either in the War Cabinet or in high executive office. The three Fighting Services have been filled. It was necessary that this should be done in one single day, on account of the extreme urgency and rigour of events. A number of other positions, key positions, were filled yesterday, and I am submitting a further list to His Majesty to-night. I hope to complete the appointment of the principal Ministers during to-morrow. the appointment of the other Ministers usually takes a little longer, but I trust that, when Parliament meets again, this part of my task will be completed, and that the administration will be complete in all respects.

I considered it in the public interest to suggest that the House should be summoned to meet today. Mr. Speaker agreed, and took the necessary steps, in accordance with the powers conferred upon him by the Resolution of the House. At the end of the proceedings today, the Adjournment of the House will be proposed until Tuesday, 21st May, with, of course, provision for earlier meeting, if need be. The business to be considered during that week will be notified to Members at the earliest opportunity. I now invite the House, by the Motion which stands in my name, to record its approval of the steps taken and to declare its confidence in the new Government.

To form an Administration of this scale and complexity is a serious undertaking in itself, but it must be remembered that we are in the preliminary stage of one of the greatest battles in history, that we are in action at many other points in Norway and in Holland, that we have to be prepared in the Mediterranean, that the air battle is continuous and that many preparations, such as have been indicated by my hon. Friend below the Gangway, have to be made here at home. In this crisis I hope I may be pardoned if I do not address the House at any length today. I hope that any of my friends and colleagues, or former colleagues, who are affected by the political reconstruction, will make allowance, all allowance, for any lack of ceremony with which it has been necessary to act. I would say to the House, as I said to those who have joined this government: "I have nothing to offer but blood, toil, tears and sweat."

We have before us an ordeal of the most grievous kind. We have before us many, many long months of struggle and of suffering. You ask, what is our policy? I can say: It is to wage war, by sea, land and air, with all our might and with all the strength that God can give us; to wage war against a monstrous tyranny, never surpassed in the dark, lamentable catalogue of human crime. That is our policy. You ask, what is our aim? I can answer in one word: It is victory, victory at all costs, victory in spite of all terror, victory, however long and hard the road may be; for without victory, there is no survival. Let that be realised; no survival for the British Empire, no survival for all that the British Empire has stood for, no survival for the urge and impulse of the ages, that mankind will move forward towards its goal. But I take up my task with buoyancy and hope. I feel sure that our cause will not be suffered to fail among men. At this time I feel entitled to claim the aid of all, and I say, "come then, let us go forward together with our united strength."
'})

Post.create({:public => true, :content => "
**HAMLET:** To be, or not to be--that is the question:  
Whether 'tis nobler in the mind to suffer  
The slings and arrows of outrageous fortune  
Or to take arms against a sea of troubles  
And by opposing end them. To die, to sleep--  
No more--and by a sleep to say we end  
The heartache, and the thousand natural shocks  
That flesh is heir to. 'Tis a consummation  
Devoutly to be wished. To die, to sleep--  
To sleep--perchance to dream: ay, there's the rub,  
For in that sleep of death what dreams may come  
When we have shuffled off this mortal coil,  
Must give us pause. There's the respect  
That makes calamity of so long life.  
For who would bear the whips and scorns of time,  
Th' oppressor's wrong, the proud man's contumely  
The pangs of despised love, the law's delay,  
The insolence of office, and the spurns  
That patient merit of th' unworthy takes,  
When he himself might his quietus make  
With a bare bodkin? Who would fardels bear,  
To grunt and sweat under a weary life,  
But that the dread of something after death,  
The undiscovered country, from whose bourn  
No traveller returns, puzzles the will,  
And makes us rather bear those ills we have  
Than fly to others that we know not of?  
Thus conscience does make cowards of us all,  
And thus the native hue of resolution  
Is sicklied o'er with the pale cast of thought,  
And enterprise of great pitch and moment  
With this regard their currents turn awry  
And lose the name of action. -- Soft you now,  
The fair Ophelia! -- Nymph, in thy orisons  
Be all my sins remembered.
"})
  
Post.create({:public => true, :content => '
[The Age of Privacy is Over](http://www.readwriteweb.com/archives/facebooks_zuckerberg_says_the_age_of_privacy_is_ov.php "The Age of Privacy is Over").    
'})

Post.create({:public => false, :content => '
This is the first private post on the system. When it is first created, only the people the demonstration user designate will have access to the content.
'})

Post.create({:public => false, :content => '
This is the second private post on the system. When it is first created, only the people the demonstration user designate will have access to the content.
'})

Post.create({:public => false, :content => '
This is the third private post on the system.
'})

Post.all.each do |post|
  post.user = demonstration_user
  post.save
end